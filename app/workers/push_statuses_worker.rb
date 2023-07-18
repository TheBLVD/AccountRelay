# frozen_string_literal: true

class PushStatusesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(url, account)
    FetchRemoteStatusesService.new.call(account, url:)
  end
end
