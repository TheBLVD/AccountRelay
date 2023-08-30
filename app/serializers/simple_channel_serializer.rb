class SimpleChannelSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :owner, :icon

  belongs_to :owner, serializer: ::SimpleUserSerializer
end
