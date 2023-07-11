# frozen_string_literal: true

class PushStatusesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(_instance_url, account)
    FetchRemoteStatusesService.new.call(account)
  end
end
