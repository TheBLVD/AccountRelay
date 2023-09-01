# frozen_string_literal: true

class SubscribeService < BaseService
  # Subscribe a user to a channel
  # @param [User] source_user that requested the subscribe
  # @param [Channel] target_channel User wants to subscribe to
  def call(source_user, target_channel, _options = {})
    @source_user = source_user
    @target_channel = target_channel

    subscribe!
  end

  def subscribe!
    @source_user.subscribe!(@target_channel)
  end
end
