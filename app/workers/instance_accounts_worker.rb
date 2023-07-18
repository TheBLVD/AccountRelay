# frozen_string_literal: true

class InstanceAccountsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(url, accounts)
    Rails.logger.info ">>>>>>>InstanceAccountsWorker: #{url}: #{accounts}"
    accounts.each do |account|
      PushStatusesWorker.perform_async(url, account)
    end
  end
end
