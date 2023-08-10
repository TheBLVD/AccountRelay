# frozen_string_literal: true

# Given a user fetch all the latest statuses
# TODO: for a given min_id (ie the last successful status retrived and sent)
class FetchUserStatusesService < BaseService
  include ActivitypubOutboxHelper
  INSTANCE_URL = 'https://staging.moth.social'

  def call(user_id, options = {})
    @user = User.find(user_id)

    Rails.logger.info "OPTIONS: >>>> #{options}"
    fetch_outbox!
  end

  # Required account handle & min_id (defaults to 0)
  def fetch_outbox!
    outbox = outbox!("#{@user.username}@#{@user.domain}")
    return if outbox.nil? || outbox.ordered_items.nil?

    outbox.ordered_items.each do |status|
      send_announcement(status)
    end
    Rails.logger.info "PREV>>>> #{outbox.prev}"

    # Update min_id for account
    return if outbox.prev.nil?

    min_id = min_id_param(outbox.prev)
    # TODO: Add min_id to user's table
    # Rails.logger.info "UPDATE_MIN_ID: >>>> #{min_id}"
    # @account.update(min_id:)
  end

  def min_id_param(url)
    uri = URI(url)
    query = URI.decode_www_form(uri.query)
    query.assoc('min_id').last
  end

  def send_announcement(status)
    return if status.dig(:object, :id).nil?

    # Check status object is hash or string
    status_url = (status[:object].is_a? String) ? status[:object] : status[:object][:id]
    content = announcement_payload(status_url)

    Rails.logger.info 'ANNOUNCMENT_CONTENT: >>>>'
    Rails.logger.info "INSTANCE_URL: >>>> #{INSTANCE_URL} is the instance it's pushing too"
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
