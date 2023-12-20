class ActivitypubOutbox
  include JsonldHelper
  class Error < StandardError; end
  class GoneError < Error; end
  class RedirectError < Error; end

  class Response
    attr_reader :uri

    def initialize(uri, body)
      @uri  = uri
      @json = Oj.load(body, symbol_keys: true)
    end

    def subject
      @json[:subject]
    end

    def ordered_items
      @json[:orderedItems]
    end

    def prev
      @json[:prev]
    end
  end

  def initialize(uri, outbox_url, min_id = nil)
    @username, @domain = uri.split('@')
    @outbox_url = outbox_url
    @min_id = min_id
    Rails.logger.info "ACPUB>> #{uri} :: #{@min_id} :: #{@outbox_url}"
    raise ArgumentError, 'Statuses requested for local account' if @domain.nil?

    @uri = uri
  end

  def perform
    Response.new(@uri, body_from_outbox)
  rescue Oj::ParseError
    raise Error, "Invalid JSON in response for #{@uri}"
  rescue Addressable::URI::InvalidURIError
    raise Error, "Invalid URI for #{@uri}"
  rescue StandardError => e
    Rails.logger.warn "Unable to fetch statuses:: #{e.message}"
    nil
  end

  private

  def body_from_outbox(url = standard_url)
    Rails.logger.info "URL REQUEST>>>: #{url}"
    outbox_request(url).perform do |res|
      raise Error, "Request for #{url} returned HTTP #{res.code}" unless res.code == 200

      res.body.to_s
    end
  end

  def outbox_request(url)
    Request.new(:get, url)
  end

  # https://staging.moth.social/users/jtomchak/outbox?min_id=0&page=true
  # No outbox_url use Mastodon outbox path
  # TODO: replace page=true with fetching the 'frist' value from outbox
  def standard_url
    return mastodon_standard_outbox_url if @outbox_url.blank?

    outbox_url
  end

  def mastodon_standard_outbox_url
    if @min_id.nil?
      "https://#{@domain}/users/#{@username}/outbox?page=true"
    else
      "https://#{@domain}/users/#{@username}/outbox?min_id=#{@min_id}&page=true"
    end
  end

  # Check for outbox_url of user
  # for the 'first' properity. This gives the params of the outbox page=true or page=1,
  # possibility other options
  def outbox_url
    build_request(@outbox_url).perform do |response|
      unless response_successful?(response) || response_error_unsalvageable?(response) || !raise_on_temporary_error
        raise AccountRelay::UnexpectedResponseError,
              response
      end
      Oj.load(response.body.to_s, symbol_keys: true)[:first]
    end
  end
end
