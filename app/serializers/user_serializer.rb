class UserSerializer < ActiveModel::Serializer
  attributes :username, :domain, :updated_at, :display_name, :following

  has_many :following, serializer: ::UserFollowingSerializer
end
