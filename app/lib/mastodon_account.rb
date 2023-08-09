class MastodonAccount
  class Error < StandardError; end
  class GoneError < Error; end
  class RedirectError < Error; end

  class Response
    attr_reader :uri, :domain, :username, :display_name, :discoverable, :domain_id, :followers_count, :following_count

    def initialize(uri, body)
      json = Oj.load(body, mode: :strict)
      @uri = uri
      @username = json['acct']
      @domain = URI.parse(uri).host
      @display_name = json['display_name']
      @discoverable = json['discoverable']
      @domain_id = json['id']
      @followers_count = json['followers_count']
      @following_count = json['following_count']
    end
  end

  def initialize(handle)
    uri = username_to_uri(handle)
    @uri = uri
  end

  def perform
    Response.new(@uri, body_from_accounts)
  rescue Oj::ParseError
    Rails.logger.warn "Invalid JSON in response for #{@uri}"
    nil
  rescue Addressable::URI::InvalidURIError
    # raise MastodonAccount::Error, "Invalid URI for #{@uri}"
    Rails.logger.warn "Invalid URI for #{@uri}"
    nil
  rescue MastodonAccount::Error, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
    Rails.logger.warn "failed for #{@uri}"
    nil
  end

  private

  def body_from_accounts(url = @uri)
    Rails.logger.info "URL REQUEST>>>: #{url}"
    accounts_request(url).perform do |res|
      # Handling 404 errors
      raise MastodonAccount::Error, "Request for #{@uri} returned HTTP #{res.code}" unless res.code == 200

      res.body.to_s
    end
  end

  def accounts_request(url)
    Request.new(:get, url)
  end

  # Returns the uri to fetch the users account information from their specific instance
  def username_to_uri(handle)
    username, domain = username_and_domain(handle)
    "https://#{domain}/api/v1/accounts/lookup?acct=#{username}"
  end

  def username_and_domain(handle)
    match = handle.match(/^(.+)@(.+)$/)
    raise StandardError, "Incorrect handle: #{handle}" if !match || match.length < 2

    domain = match[2]
    username = match[1]
    [username, domain]
  end
end
