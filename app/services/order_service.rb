class OrderService
  class InsufficientStockError < StandardError; end
  class InvalidOrderError < StandardError; end

  def initialize(order)
    @order = order
  end

  def create(params)
    ActiveRecord::Base.transaction do
      @order = Order.new
      process_order_items(params[:order_items_attributes])
      @order.save!
      @order
    end
  rescue ActiveRecord::RecordInvalid => e
    raise InvalidOrderError, e.message
  end

  def self.find(id)
    Order.includes(:order_items, :products).find(id)
  end

  def self.list(page: 1, per_page: 10)
    Order.includes(:order_items, :products)
         .page(page)
         .per(per_page)
  end

  def process_order
    @order.order_items.each do |item|
      product = item.product
      product.update!(quantity: product.quantity - item.quantity)
    end
    @order.update!(status: 'processing')
  end

  def cancel_order
    @order.order_items.each do |item|
      product = item.product
      product.update!(quantity: product.quantity + item.quantity)
    end
    @order.update!(status: 'cancelled')
  end

  def complete_order
    @order.update!(status: 'completed')
  end

  def calculate_total
    @order.order_items.sum { |item| item.quantity * item.price_at_time_of_order }
  end

  def validate_order
    @order.order_items.each do |item|
      product = item.product
      return false unless product.can_be_ordered?(item.quantity)
    end
    true
  end

  private

  def process_order_items(items_attributes)
    return if items_attributes.blank?

    items_attributes.each do |item_attrs|
      product = Product.find(item_attrs[:product_id])
      quantity = item_attrs[:quantity].to_i

      raise InsufficientStockError, "Insufficient stock for product #{product.name}" if product.quantity < quantity

      @order.order_items.build(
        product: product,
        quantity: quantity,
        price_at_time_of_order: product.price
      )

      product.update!(quantity: product.quantity - quantity)
    end
  end

  def calculate_total_with_discount(discount_percentage)
    @order.total_amount * (1 - discount_percentage / 100.0)
  end
end