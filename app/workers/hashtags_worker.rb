# frozen_string_literal: true

# Define a new worker that will be used to fetch hashtags
class HashtagsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform(instance_url, tags)
    tags.each do |tag|
      Rails.logger.info "HashtagsWorker:: Fetching #{tag} from #{instance_url}"
      FetchHashtagService.new.call(tag, instance_url:)
    end
  end
end
