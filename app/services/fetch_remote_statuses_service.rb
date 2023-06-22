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
    end
  end
end
