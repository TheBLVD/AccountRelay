class MastodonFollowing
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

  def initialize(user)
    @user = user
    @uri = user_to_following_uri
  end

  def perform
    direct_follows
    # Response.new(@uri, body_from_accounts)
  rescue Oj::ParseError
    raise MastodonFollowing::Error, "Invalid JSON in response for #{@uri}"
  rescue Addressable::URI::InvalidURIError
    raise MastodonFollowing::Error, "Invalid URI for #{@uri}"
  end

  private

  def follows_request(url)
    Request.new(:get, url)
  end

  # Optional account id.
  # returns an array of hashes containing all the accounts details followed by `@handle`:
  # type AccountDetails = {
  #   id: string
  #   username: string
  #   acct: string
  #   followed_by: Set<string> // list of handles
  #   following_count: number
  #   followers_count: number
  #   discoverable: boolean
  #   display_name: string
  #   note: string
  #   locked: boolean
  #   bot: boolean
  #   group: boolean
  #   discoverable: boolean
  #   avatar_static: string
  #   header: string
  #   header_static: string
  # }
  def direct_follows
    domain = @user.domain

    next_page = @uri
    data = []
    while next_page
      follows_request(next_page).perform do |res|
        raise MastodonFollowing::Error, "Request for #{next_page} returned HTTP #{res.code}" if res.code != 200

        page = JSON.parse(res.body, object_class: OpenStruct)
        data += page
        next_page = get_next_page(res['Link'])
      end
    end
    data
  rescue StandardError => e
    Rails.logger.error("Cannot find following for user:  #{@user.username}@#{@user.domain}: #{e}")
    next_page = nil
    []
  end

  def get_next_page(link_header)
    return nil unless link_header

    # Example header:
    # Link: <https://mastodon.example/api/v1/accounts/1/follows?limit=2&max_id=7628164>; rel="next", <https://mastodon.example/api/v1/accounts/1/follows?limit=2&since_id=7628165>; rel="prev"
    match = link_header.match(/<(.+)>; rel="next"/)
    match && match[1]
  end

  # Returns the uri to fetch the users account information from their specific instance
  # https://moth.social/api/v1/accounts/109999818134873647/following
  def user_to_following_uri
    "https://#{@user.domain}/api/v1/accounts/#{@user.domain_id}/following"
  end
end
