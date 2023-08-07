# frozen_string_literal: true

class DirectFollowingWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(user)
    FetchUserFollowingService.new.call(user)
  end
end
