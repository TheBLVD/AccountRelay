# frozen_string_literal: true

class PushStatusesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(url, account)
    handle, min_id = account
    # Rails.logger.info ">>>>>>>PushStatusesWorker: #{handle}"
    # Rails.logger.info ">>>>>>>PushStatusesWorker: #{min_id}"
    FetchRemoteStatusesService.new.call(handle, url:, min_id:)
  end
end
