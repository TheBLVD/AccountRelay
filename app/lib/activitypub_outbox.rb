class ActivitypubOutbox
  include JsonldHelper
  class Error < StandardError; end
  class GoneError < Error; end
  class RedirectError < Error; end

  class Response
    attr_reader :uri

    def initialize(uri, body)
      @uri  = uri
      @json = body
    end

    def subject
      @json[:subject]
    end

    def ordered_items
      @json[:orderedItems]
    end

    def collection_items
      collection = outbox_collection
      case collection[:type]
      when 'Collection', 'CollectionPage'
        collection[:items]
      when 'OrderedCollection', 'OrderedCollectionPage'
        collection[:orderedItems]
      end
    end

    def outbox_collection
      if @json[:first].present? && @json[:first].is_a?(Hash)
        @json[:first]
      else
        @json
      end
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

  # Return Parsed Outbox Body
  # if 'first' is a hash or 'orderedItems' that's what we want. return that result
  # otherwise 'first' is a uri, likely the save with url query params `page=true` or `page=1`
  def body_from_outbox(url = standard_url)
    Rails.logger.info "URL REQUEST>>>: #{url}"
    outbox_collection = fetch_outbox(url)
    return outbox_collection if outbox_collection[:first].is_a?(Hash) || outbox_collection[:orderedItems].present?

    fetch_outbox(outbox_collection[:first]) if outbox_collection[:first].present?
  end

  # https://staging.moth.social/users/jtomchak/outbox?min_id=0&page=true
  # No outbox_url use Mastodon outbox path
  def standard_url
    Rails.logger.debug "OUTBOX IS: #{@outbox_url.blank?}"
    return mastodon_standard_outbox_url if @outbox_url.blank?

    @outbox_url
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
  def fetch_outbox(uri)
    build_request(uri).perform do |response|
      unless response_successful?(response) || response_error_unsalvageable?(response) || !raise_on_temporary_error
        raise AccountRelay::UnexpectedResponseError,
              response
      end
      Oj.load(response.body.to_s, symbol_keys: true)
    end
  end
end
