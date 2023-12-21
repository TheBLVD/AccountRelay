# frozen_string_literal: true

# Given a user fetch all the latest statuses
# TODO: for a given min_id (ie the last successful status retrived and sent)
class FetchUserStatusesService < BaseService
  include ActivitypubOutboxHelper
  INSTANCE_URL = 'https://moth.social'

  def call(user_id, username, domain, outbox_url)
    @user_id = user_id
    @username = username
    @domain = domain
    @outbox_url = outbox_url
    @status_min_id = StatusManager.instance.fetch_min_id(@user_id)

    Rails.logger.info "OPTIONS: >>>> #{@status_min_id}"
    fetch_outbox!
  end

  # Required account handle & min_id (defaults to 0)
  def fetch_outbox!
    outbox = outbox!("#{@username}@#{@domain}", @outbox_url, @status_min_id)
    Rails.logger.info "OPTIONS: >>>> #{outbox}"
    return if outbox.nil? || outbox.ordered_items.nil? || outbox.ordered_items.empty?

    if @status_min_id.nil?
      Rails.logger.info 'NO MIN_ID FOUND: SEND ONLY MOST RECENT STATUS'
      Rails.logger.info "ORDERED ITEMS COUNT: #{outbox.ordered_items.count}"
      status = outbox.ordered_items.first
      send_announcement(status)
    else
      outbox.ordered_items.each do |status|
        send_announcement(status)
      end
    end

    return if outbox.prev.nil?

    # Update min_id for account
    Rails.logger.info "PREV>>>> #{outbox.prev}"
    min_id = min_id_param(outbox.prev)
    StatusManager.instance.update_min_id(@user_id, min_id)
  end

  def min_id_param(url)
    uri = URI(url)
    query = URI.decode_www_form(uri.query)
    query.assoc('min_id').last
  end

  def send_announcement(status)
    # Check status object is hash or string
    status_url = (status[:object].is_a? String) ? status[:object] : status[:object][:id]
    return if status_url.nil?

    Rails.logger.debug "STATUS URL: \n\n #{status_url}"

    content = announcement_payload(status_url)

    Rails.logger.info "ANNOUNCMENT_CONTENT: >>>> #{status_url}"
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
