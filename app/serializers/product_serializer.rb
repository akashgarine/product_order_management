class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :sku, :price, :quantity, :active, :created_at, :updated_at
end