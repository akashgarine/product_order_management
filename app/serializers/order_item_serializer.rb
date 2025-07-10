class OrderItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :price_at_time_of_order, :created_at, :updated_at

  belongs_to :product
end