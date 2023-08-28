class ChannelSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :owner

  belongs_to :owner, serializer: ::SimpleUserSerializer
  has_many :accounts, serializer: ::ChannelAccountSerializer
end
