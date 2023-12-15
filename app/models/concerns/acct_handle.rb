module AcctHandle
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    # find user by fully qualified handle <jtomchak@moth.social>
    def by_handle(handle)
      username, domain = username_and_domain(handle)
      where(username:, domain:).take
    end

    # Create user if it doesn't exist
    def create_by_remote(acct)
      account = MastodonAccount.new(acct).perform
      return account if account.nil?

      User.find_or_create_by(username: account.username, domain: account.domain, discoverable: account.discoverable,
                             display_name: account.display_name, domain_id: account.domain_id, followers_count: account.followers_count, following_count: account.following_count, local: false)
    end

    def username_and_domain(handle)
      match = handle.match(/^(.+)@(.+)$/)
      raise StandardError, "Incorrect handle: #{handle}" if !match || match.length < 2

      domain = match[2]
      username = match[1]
      [username, domain]
    end
  end
end
