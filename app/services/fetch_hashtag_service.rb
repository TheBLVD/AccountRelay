# frozen_string_literal: true

# Fetch all statuses for a given hashtag
class FetchHashtagService < BaseService
  INSTANCE_URL = 'https://staging.moth.social'

  def call(hashtag, options = {})
    @hashtag = hashtag
    @instance_url = options[:instance_url]
    @limit = options[:limit] || 40
    Rails.logger.info "OPTIONS: >>>> #{options}"
    fetch_hashtag!
  end

  def fetch_hashtag!
    response = HTTP.get("https://#{@instance_url}/api/v1/timelines/tag/#{@hashtag}?limit=#{@limit}")
    statuses = response.parse

    Rails.logger.info "RESPONSE: >>>> #{statuses}"

    return if statuses.nil?

    statuses.each do |status|
      # TODO: filter statuses that have low engagement
      send_announcement(status['uri'])
    end
  end

  def send_announcement(status_url)
    content = announcement_payload(status_url)
    Rails.logger.info "CONTENT: >>>> #{content}"
    SendMessageToInboxService.new.call(INSTANCE_URL, content)
  end

  def announcement_payload(status_url)
    @relay = 'https://acctrelay.moth.social'
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      actor: "#{@relay}/actor",
      id: "#{@relay}/activities/#{SecureRandom.uuid}",
      type: 'Announce',
      object: {
        id: status_url.to_s
      },
      to: [
        "#{@relay}/followers"
      ]
    }
  end
end
