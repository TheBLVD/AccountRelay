class UserFollowingSerializer < ActiveModel::Serializer
  attributes :username, :domain, :display_name
end
