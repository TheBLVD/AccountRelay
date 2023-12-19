# frozen_string_literal: true

module ActivitypubOutboxHelper
  def outbox!(uri, outbox_url, min_id = nil)
    Rails.logger.info "ActivitypubOutboxHelper>> #{uri} :: #{min_id}"
    ActivitypubOutbox.new(uri, outbox_url, min_id).perform
  end
end
