# frozen_string_literal: true

class Scheduler::UpdateHashtagsScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    HashtagsWorker.new.perform('chaos.social', ['keynote'])
  end
end
