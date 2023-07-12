# frozen_string_literal: true

class PushStatusesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(instance_url, account)
    Rails.logger.info ">>>>>>>InstanceAccountsWorker: #{account}"
    FetchRemoteStatusesService.new.call(account, url: instance_url)
  end
end
