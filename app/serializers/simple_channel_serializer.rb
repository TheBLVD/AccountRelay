class SimpleChannelSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :owner

  belongs_to :owner, serializer: ::SimpleUserSerializer
end
