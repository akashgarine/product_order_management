class ProductService
  def initialize(product = nil)
    @product = product
  end

  def create(params)
    @product = Product.new(params)
    @product.save
    @product
  end

  def update(params)
    @product.update(params)
    @product
  end

  def destroy
    @product.update(active: false)
  end

  def self.search(query, page: 1, per_page: 10)
    products = Product.active
    products = products.where('name LIKE :query OR sku LIKE :query', query: "%#{query}%") if query.present?
    products.page(page).per(per_page)
  end

  def self.find(id)
    Product.find(id)
  end

  def can_be_ordered?(quantity)
    @product.quantity >= quantity
  end
end