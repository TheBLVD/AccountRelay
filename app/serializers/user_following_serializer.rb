class UserFollowingSerializer < ActiveModel::Serializer
  attributes :username, :domain, :display_name, :domain_id
end
