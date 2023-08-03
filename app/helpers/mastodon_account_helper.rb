# frozen_string_literal: true

module MastodonAccountHelper
  def remote_account(handle)
    Rails.logger.info "MastodonAccountHelper>> #{handle}"
    MastodonAccount.new(handle).perform
  end
end
