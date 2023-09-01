class AdvanceUserSerializer < ActiveModel::Serializer
  attributes :username, :domain, :acct, :display_name, :for_you_settings

  attribute :subscribed_channels

  def subscribed_channels
    object.subscribes.map do |ii|
      ::SimpleChannelSerializer.new(ii)
    end
  end
end
