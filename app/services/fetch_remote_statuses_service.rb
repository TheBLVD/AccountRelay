# frozen_string_literal: true

# Given an account fetch all the latest statuses
# for a given min_id (ie the last successful status retrived and sent)
class FetchRemoteStatusesService < BaseService
  include ActivitypubOutboxHelper
  def call(account, options = {})
    if account.is_a?(Account)
      @account = account
      @username = @account.username
      @domain   = @account.domain
      @instance_url = options[:url]
      Rails.logger.info "OPTIONS: >>>> #{options}"
    else
      @username, @domain = account.strip.gsub(/\A@/, '').split('@')
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
    content = announcement_payload(status['object']['id'])
    Rails.logger.info 'ANNOUNCMENT_CONTENT: >>>>'
    Rails.logger.info "INSTANCE_URL: >>>> #{@instance_url} is the instance it's pushing too"
    # TODO: Update to variable. Needs to be the Instance_id URL
    SendMessageToInboxService.new.call('https://staging.moth.social', content)
  end

  def announcement_payload(status_url)
    @relay = 'https://acctrelay.moth.social'
    {
      "@context": 'https://www.w3.org/ns/activitystreams',
      'actor': "#{@relay}/actor",
      'id': "#{@relay}/activities/#{SecureRandom.uuid}",
      'type': 'Announce',
      'object': {
        'id': status_url.to_s
      },
      "to": [
        "#{@relay}/followers"
      ]
    }
  end
end
