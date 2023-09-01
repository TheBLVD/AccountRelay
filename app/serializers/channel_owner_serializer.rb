class ChannelOwnerSerializer < ActiveModel::Serializer
  attributes :username, :domain, :acct, :display_name
end
