class ProductService
  def initialize(product = nil)
    @product = product
  end

  def create(params)
    @product = Product.new(params)
    raise ActiveRecord::RecordInvalid.new(@product) unless @product.save
    @product.save
    @product
  end

  def update(params)
    raise ActiveRecord::RecordNotFound unless @product
    raise ActiveRecord::RecordInvalid.new(@product) unless @product.update(params)
    @product
  end

  def destroy
    raise ActiveRecord::RecordNotFound unless @product
    raise "Product already inactive" unless @product.active?
    @product.update(active: false)
  end

  def self.search(query, page: 1, per_page: 10)
    products = Product.active
        if query.present?
      sanitized = ActiveRecord::Base.sanitize_sql_like(query)
      products = products.where('name ILIKE :query OR sku ILIKE :query', query: "%#{sanitized}%")
    end

    products.page(page).per(per_page)
  end

  def self.find(id)
    Product.find(id)
  end

  def can_be_ordered?(quantity)
    @product.present? && @product.quantity >= quantity
  end
end