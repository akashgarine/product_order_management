class BusinessSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :business_type, :status, :active
  has_many :products
end