# frozen_string_literal: true

module MastodonHelper
  def remote_account(handle)
    Rails.logger.info "MastodonHelper>> #{handle}"
    MastodonAccount.new(handle).perform
  end

  def direct_follows(user)
    Rails.logger.info "MastodonHelper>> #{user.username}@#{user.domain}"
    MastodonFollowing.new(user).perform
  end
end
