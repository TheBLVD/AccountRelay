# frozen_string_literal: true

require 'http'
require 'json'

# Get instances -here `insta.accounts.group(:handle).pluck(:handle)`
# Get accounts for each instance (grouped) -workerA
# Each Account is sent to fetch_remote_statuses_service (that will fetch and send the statuses for that account) -workerB
class Scheduler::UpdateAccountStatusesScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    instances.each do |instance|
      id, url = instance
      accounts = instance_accounts(id)
      InstanceAccountsWorker.perform_async(url, accounts)
    end
  end

  private

  def instances
    Instance.all.pluck(:id, :url)
  end

  # def accounts_by_instance
  #   allInstances = Instance.all.pluck(:id, :url)
  #   instance_accounts = allInstances.map do |instance|
  #     id, url = instance
  #     { 'url' => url, 'accounts' => instance_handles(id) }
  #   end
  #   Rails.logger.debug ">>>>>> #{instance_accounts}"
  # end

  def instance_accounts(id)
    Instance.find(id).accounts.group(:handle).pluck(:handle)
  end
end
