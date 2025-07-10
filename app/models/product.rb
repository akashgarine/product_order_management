class Product < ApplicationRecord
  belongs_to :business
  has_many :order_items
  has_many :orders, through: :order_items

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :sku, presence: true, uniqueness: true, format: { with: /\A[A-Z0-9]+\z/ }
  validates :price, presence: true, numericality: { greater_than: 0, precision: 10, scale: 2 }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }

  scope :active, -> { where(active: true) }
  scope :search, ->(query) { where('name LIKE :query OR sku LIKE :query', query: "%#{query}%") }

  def can_be_ordered?(quantity)
    active? && quantity > 0 && self.quantity >= quantity
  end

  def self.bulk_update(products_data)
    products_data.each do |data|
      find(data[:id]).update(data.except(:id))
    end
  end

  def soft_delete
    update(active: false)
  end
end