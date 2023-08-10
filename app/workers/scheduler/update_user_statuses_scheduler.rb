# frozen_string_literal: true

require 'http'
require 'json'

# Get users
# Each User is sent to fetch_remote_statuses_service (that will fetch and send the statuses for that account) -workerB
class Scheduler::UpdateUserStatusesScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    users.each do |user_id|
      UserStatusesWorker.perform_async(user_id)
    end
  end

  private

  def users
    User.all.pluck(:id)
  end
end
