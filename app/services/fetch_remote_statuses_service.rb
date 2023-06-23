# frozen_string_literal: true

# Given an account fetch all the latest statuses
# for a given min_id (ie the last successful status retrived and sent)
class FetchRemoteStatusesService < BaseService
  include ActivitypubOutboxHelper
  def call(uri, _options = {})
    if uri.is_a?(Account)
      @account = uri
      @username = @account.username
      @domain   = @account.domain
    else
      @username, @domain = uri.strip.gsub(/\A@/, '').split('@')
    end
    fetch_outbox!
  end

  # Required account handle & min_id (defaults to 0)
  def fetch_outbox!
    outbox = outbox!("#{@username}@#{@domain}", 0)
    outbox.ordered_items.each do |status|
      Rails.logger.info '>>>>>>>>'
      Rails.logger.info status
      send_announcement(status)
    end
  end

  def send_announcement(status)
    content = announcement_payload(status['object']['url'])
    Rails.logger.info "ANNOUNCMENT_CONTENT: >>>> #{content}"
    SendMessageToInboxService.new.call('https://staging.moth.social', content)
  end

  def announcement_payload(status_url)
    @relay = 'https://acctrelay.moth.social'
    {
      "@context": 'https://www.w3.org/ns/activitystreams',
      'actor': "#{@relay}/actor",
      'id': "#{@relay}/activities/#{SecureRandom.uuid}",
      'type': 'Announce',
      'object': status_url.to_s,
      "to": [
        "#{@relay}/followers"
      ]
    }
  end
end
