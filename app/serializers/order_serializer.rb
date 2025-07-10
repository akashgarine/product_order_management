class OrderSerializer < ActiveModel::Serializer
  attributes :id, :total_amount, :created_at, :updated_at

  has_many :order_items
  has_many :products, through: :order_items
end