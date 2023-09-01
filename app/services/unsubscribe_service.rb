# frozen_string_literal: true

class UnsubscribeService < BaseService
  # Unsubscribe a user from a channel
  # @param [User] source_user that requested the unsubscribe
  # @param [Channel] target_channel User wants to unsubscribe from
  def call(source_user, target_channel, _options = {})
    @source_user = source_user
    @target_channel = target_channel

    unsubscribe!
  end

  def unsubscribe!
    @source_user.unsubscribe!(@target_channel)
  end
end
