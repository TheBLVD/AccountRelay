class SimpleChannelSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :icon
  attribute :owner

  # Conditionally render accounts if `include_accounts` as a param is passed
  has_many :accounts, serializer: ::ChannelAccountSerializer, if: -> { should_render_association }

  def owner
    ::ChannelOwnerSerializer.new(object.owner)
  end

  def should_render_association
    @instance_options[:show_accounts]
  end
end
