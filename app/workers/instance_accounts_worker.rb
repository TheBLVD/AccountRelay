# frozen_string_literal: true

class InstanceAccountsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(url, accounts)
    Rails.logger.info "InstanceAccountsWoker_Accounts>> #{accounts}"
    accounts.each do |account|
      Rails.logger.info "InstanceAccountsWorker_single_account>> #{account}"
      PushStatusesWorker.perform_async(url, account)
    end
  end
end
