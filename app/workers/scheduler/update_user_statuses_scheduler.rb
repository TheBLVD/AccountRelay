# frozen_string_literal: true

require 'http'
require 'json'

# Get users
# Each User is sent to fetch_remote_statuses_service (that will fetch and send the statuses for that account) -workerB
class Scheduler::UpdateUserStatusesScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    # defaults to a 1_000 into redis at a time
    UserStatusesWorker.perform_bulk(users)
  end

  private

  def users
    User.all.pluck(:user_id, :username, :domain, :outbox_url).zip
  end
end
