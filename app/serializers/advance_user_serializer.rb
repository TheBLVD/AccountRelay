class AdvanceUserSerializer < ActiveModel::Serializer
  attributes :username, :domain, :acct, :display_name, :for_you_settings
end
