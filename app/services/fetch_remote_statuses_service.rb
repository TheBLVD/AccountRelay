# frozen_string_literal: true

# https://staging.moth.social/users/jtomchak/outbox?min_id=0&page=true
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
    @outbox = outbox!("#{@username}@#{@domain}", 0)
  end
end
