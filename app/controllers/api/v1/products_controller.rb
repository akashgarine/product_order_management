module Api
  module V1
    class ProductsController < ApplicationController
      before_action :authenticate_business!, only: [:create, :update, :destroy]
      before_action :set_product, only: [:show, :update, :destroy]
      before_action :authorize_product!, only: [:update, :destroy]

      def index
        @products = Product.active.page(params[:page]).per(params[:per_page])
        render json: ActiveModel::Serializer::CollectionSerializer.new(
          @products,
          serializer: ProductSerializer,
          meta: pagination_meta(@products)
        )
      end

      def show
        if @product
        render json: ProductSerializer.new(@product)
      end

      def create
        @product = current_business.products.build(product_params)
        if @product.save
          render json: ProductSerializer.new(@product), status: :created
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @product.update(product_params)
          render json: ProductSerializer.new(@product)
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @product.soft_delete
          head :no_content
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def search
        if params[:query].blank?
          render json: { errors: ['Query parameter is missing or blank'] }, status: :bad_request
          return
        end

        @products = Product.search(params[:query])
          .where(business_id: current_business.id) 
          .page(params[:page]).per(params[:per_page])

        render json: ActiveModel::Serializer::CollectionSerializer.new(
          @products,
          serializer: ProductSerializer,
          meta: pagination_meta(@products)
        )
      end

      private

      def set_product
        @product = Product.find_by(id:params[:id])
        unless @product
          render json: { errors: ['Product not found'] }, status: :not_found
        end
      end

      def authorize_product!
        return unless @product # skip if product not found
        unless @product.business_id == current_business&.id
          render json: { errors: ['Not authorized to access this product'] }, status: :forbidden
        end
      end
      
      def product_params
        params.require(:product).permit(:name, :description, :price, :quantity, :sku)
      end

      def authenticate_business!
        unless current_business
          render json: { errors: ['Not Authorized'] }, status: :unauthorized
        end
      end

      def pagination_meta(object)
        {
          current_page: object.current_page,
          next_page: object.next_page,
          prev_page: object.prev_page,
          total_pages: object.total_pages,
          total_count: object.total_count
        }
      end
    end
  end
end