class SimpleChannelSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :icon

  attribute :owner

  def owner
    ::ChannelOwnerSerializer.new(object.owner)
  end
end
