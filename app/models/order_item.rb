class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_at_time_of_order, presence: true, numericality: { greater_than: 0 }

  before_validation :set_price_at_time_of_order

  private

  def set_price_at_time_of_order
    self.price_at_time_of_order = product.price if product
  end
end