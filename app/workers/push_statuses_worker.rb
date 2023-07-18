# frozen_string_literal: true

class PushStatusesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(url, account)
    Rails.logger.info ">>>>>>>PushStatusesWorker: #{account}"
    handle, min_id = account
    FetchRemoteStatusesService.new.call(handle, url:, min_id:)
  end
end
