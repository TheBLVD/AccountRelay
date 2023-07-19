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
    else
      @username, @domain = account.strip.gsub(/\A@/, '').split('@')
      @account = Account.where(username: @username, domain: @domain).first
    end
    @instance_url = options[:url]
    Rails.logger.info "OPTIONS: >>>> #{options}"
    Rails.logger.info "Account>>>> #{@account.min_id}"
    fetch_outbox!
  end

  # Required account handle & min_id (defaults to 0)
  def fetch_outbox!
    outbox = outbox!("#{@username}@#{@domain}", @account.min_id)
    outbox.ordered_items.each do |status|
      send_announcement(status)
    end
    Rails.logger.info "PREV>>>> #{outbox.prev}"

    # Update min_id for account
    return if outbox.prev.nil?

    min_id = min_id_param(outbox.prev)
    Rails.logger.info "UPDATE_MIN_ID: >>>> #{min_id}"
    @account.update(min_id:)
  end

  def min_id_param(url)
    uri = URI(url)
    query = URI.decode_www_form(uri.query)
    query.assoc('min_id').last
  end

  def send_announcement(status)
    content = announcement_payload(status['object']['id'])
    Rails.logger.info 'ANNOUNCMENT_CONTENT: >>>>'
    Rails.logger.info "INSTANCE_URL: >>>> #{@instance_url} is the instance it's pushing too"
    SendMessageToInboxService.new.call(@instance_url, content)
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
