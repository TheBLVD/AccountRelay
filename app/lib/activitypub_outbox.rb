class ActivitypubOutbox
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

  def initialize(uri, min_id = nil)
    @username, @domain = uri.split('@')
    @min_id = min_id
    Rails.logger.info "ACPUB>> #{uri} :: #{min_id}"
    raise ArgumentError, 'Statuses requested for local account' if @domain.nil?

    @uri = uri
  end

  def perform
    Response.new(@uri, body_from_outbox)
  rescue Oj::ParseError
    raise ActivityPubOutbox::Error, "Invalid JSON in response for #{@uri}"
  rescue Addressable::URI::InvalidURIError
    raise ActivityPubOutbox::Error, "Invalid URI for #{@uri}"
  end

  private

  def body_from_outbox(url = standard_url)
    Rails.logger.info "URL REQUEST>>>: #{url}"
    outbox_request(url).perform do |res|
      raise ActivityPubOutbox::Error, "Request for #{@uri} returned HTTP #{res.code}" unless res.code == 200

      res.body.to_s
    end
  end

  def outbox_request(url)
    Request.new(:get, url)
  end

  # https://staging.moth.social/users/jtomchak/outbox?min_id=0&page=true
  def standard_url
    if @min_id.nil?
      "https://#{@domain}/users/#{@username}/outbox?page=true"
    else
      "https://#{@domain}/users/#{@username}/outbox?min_id=#{@min_id}&page=true"
    end
  end
end
