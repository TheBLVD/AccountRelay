# frozen_string_literal: true

require 'http'
require 'json'

# Get users that are accounts of any and all Channels
# Each User is sent to FetchUserStatusesService (that will fetch and send the statuses for that account) -workerB
class Scheduler::UpdateChannelAcctStatusesScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    # defaults to a 1_000 into redis at a time
    UserStatusesWorker.perform_bulk(channel_accounts)
  end

  private

  def channel_accounts
    ChannelAccount.all.includes(:user).pluck(:user_id, :username, :domain, :outbox_url).zip
  end
end
