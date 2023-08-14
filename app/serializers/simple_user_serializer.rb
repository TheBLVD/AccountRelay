class SimpleUserSerializer < ActiveModel::Serializer
  attributes :username, :domain, :acct, :display_name
end
