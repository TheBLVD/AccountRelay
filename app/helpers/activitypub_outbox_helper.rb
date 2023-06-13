# frozen_string_literal: true

module ActivitypubOutboxHelper
  def outbox!(uri, min_id)
    ActivitypubOutbox.new(uri, min_id).perform
  end
end
