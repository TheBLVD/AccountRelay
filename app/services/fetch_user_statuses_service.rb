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
    @status_last_known_id = StatusManager.instance.last_known_id(@user_id)

    Rails.logger.info "OPTIONS: >>>> #{@status_min_id}"
    fetch_outbox!
  end

  # Required account handle & min_id (defaults to nil)
  def fetch_outbox!
    outbox = outbox!("#{@username}@#{@domain}", @outbox_url, @status_min_id)
    return if outbox.nil? || outbox.collection_items.nil? || outbox.collection_items.empty?

    if @outbox_url.nil?
      process_collection_mastodon(outbox)
    else
      process_collection_ap(outbox)
    end
  end

  # General ActivityPub Outbox
  # Status Id's are often the post's uri
  # Example (https://fed.brid.gy/r/https://snarfed.org/2024-01-09_51795#bridgy-fed-create)
  # Send Accountments until the status id matches the last_known_id, this means we've already
  # seen and/or sent those posts over to relay
  def process_collection_ap(outbox)
    if @status_last_known_id.nil?
      Rails.logger.info 'NO LAST_KNOWN FOUND: SEND ONLY MOST RECENT STATUS'
      Rails.logger.info "ORDERED ITEMS COUNT: #{outbox.collection_items.count}"
      status = outbox.collection_items.first
      send_announcement(status)
    else
      outbox.collection_items.take_while { |i| i[:id] == @last_known_id }.each do |status|
        send_announcement(status)
      end
    end

    # Update last_known_id
    # The status_id of the most recent post from the outbox
    Rails.logger.info "LAST KNOWN ID>>  #{outbox.collection_items[0][:id]}"
    StatusManager.instance.update_last_known_id(@user_id, outbox.collection_items[0][:id])
  end

  # Mastodon Specific Outbox with Prev/Next Status Id's
  # Used before checking AP Outboxes generally
  # [Depreciated]
  def process_collection_mastodon(outbox)
    if @status_min_id.nil?
      Rails.logger.info 'NO MIN_ID FOUND: SEND ONLY MOST RECENT STATUS'
      Rails.logger.info "UNORDERED ITEMS COUNT: #{outbox.collection_items.count}"
      status = outbox.collection_items.first
      send_announcement(status)
    else
      outbox.collection_items.each do |status|
        send_announcement(status)
      end
    end

    return if outbox.prev.nil?

    # Update min_id for account
    # TODO: change from min_id to last_known_id
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

    Rails.logger.debug "STATUS URL: \n\n #{status_url}: #{status[:id]}"

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
