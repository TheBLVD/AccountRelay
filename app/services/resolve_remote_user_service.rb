class ResolveRemoteUserService
  include MastodonHelper
  def call(acct, _options = {})
    @acct = acct
  end

  def user_from_follow(follow)
    # create/get User
    remote_account = remote_account(@acct)
    return if remote_account.nil?

    user = User.where(username: follow.username,
                      domain: follow.domain).first

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
