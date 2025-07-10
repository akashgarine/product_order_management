class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role, :active
  has_many :orders
end