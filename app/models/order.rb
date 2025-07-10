class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items
  has_many :products, through: :order_items

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending processing completed cancelled] }

  accepts_nested_attributes_for :order_items

  before_validation :calculate_total_amount

  def cancel
    return false unless can_be_cancelled?

    order_items.each do |item|
      item.product.update!(quantity: item.product.quantity + item.quantity)
    end
    update!(status: 'cancelled')
  end

  private

  def calculate_total_amount
    self.total_amount = order_items.sum { |item| item.quantity * item.price_at_time_of_order }
  end

  def can_be_cancelled?
    !cancelled? && created_at > 24.hours.ago
  end
end