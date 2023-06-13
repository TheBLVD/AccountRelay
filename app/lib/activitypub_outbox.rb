class ActivitypubOutbox
  class Error < StandardError; end
  class GoneError < Error; end
  class RedirectError < Error; end

  class Response
    attr_reader :uri

    def initialize(uri, body)
      @uri  = uri
      @json = Oj.load(body, mode: :strict)

      validate_response!
    end

    def subject
      @json['subject']
    end

    def link(rel, attribute)
      links.dig(rel, attribute)
    end

    private

    def links
      @links ||= @json['links'].index_by { |link| link['rel'] }
    end

    def validate_response!
      raise ActivityPubOutbox::Error, "Missing subject in response for #{@uri}" if subject.blank?
    end
  end

  def initialize(uri, min_id = 0)
    @username, @domain = uri.split('@')
    @min_id = min_id

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
    outbox_request(url).perform do |res|
      if res.code == 200
        body = res.body_with_limit
        raise ActivityPubOutbox::Error, "Request for #{@uri} returned empty response" if body.empty?

        body
      elsif res.code == 410
        raise ActivityPubOutbox::GoneError, "#{@uri} is gone from the server"
      else
        raise ActivityPubOutbox::Error, "Request for #{@uri} returned HTTP #{res.code}"
      end
    end
  end

  def outbox_request(url)
    Request.new(:get, url).add_headers('Accept' => 'application/jrd+json, application/json')
  end

  # https://staging.moth.social/users/jtomchak/outbox?min_id=0&page=true
  def standard_url
    "https://#{@domain}/users/#{@username}/outbox?min_id=#{@min_id}&page=true"
  end
end
