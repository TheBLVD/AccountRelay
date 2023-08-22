# frozen_string_literal: true

# For Each user fetch & process statuses from their respective outbox
class UserStatusesWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 0

  def perform(user)
    user_id, username, domain = user
    Rails.logger.info "UserStatusesWorker:: #{user_id}, #{username}, #{domain}"
    FetchUserStatusesService.new.call(user_id, username, domain)
  end
end
