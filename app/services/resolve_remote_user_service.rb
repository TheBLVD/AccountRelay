# Only valid for Mastodon Accounts
# Update remote_account -> ResolveUserService
class ResolveRemoteUserService
  include MastodonHelper
  def call(acct, _options = {})
    @acct = acct

    user_from_remote_handle
  end

  def user_from_remote_handle
    # create/get User
    remote_account = remote_account(@acct)
    return if remote_account.nil?

    Rails.logger.debug "REMOTE ACCOUNT>> #{remote_account.inspect}"
    user = User.where(username: remote_account.username,
                      domain: remote_account.domain).first

    user || User.create(username: remote_account.username, domain: remote_account.domain) do |user|
      user.discoverable = remote_account.discoverable
      user.display_name = remote_account.display_name
      user.domain_id = remote_account.domain_id
      user.domain = remote_account.domain
      user.followers_count = remote_account.followers_count
      user.following_count = remote_account.following_count
    end
  end
end
