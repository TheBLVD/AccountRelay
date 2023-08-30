class ChannelSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :owner, :icon

  belongs_to :owner, serializer: ::SimpleUserSerializer
  has_many :accounts, serializer: ::ChannelAccountSerializer
end
