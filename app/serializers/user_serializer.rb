class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :domain, :updated_at
end
