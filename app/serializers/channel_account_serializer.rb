class ChannelAccountSerializer < ActiveModel::Serializer
  attributes :acct, :display_name, :username, :domain
end
