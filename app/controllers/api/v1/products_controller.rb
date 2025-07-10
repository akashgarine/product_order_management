module Api
  module V1
    class ProductsController < ApplicationController
      before_action :authenticate_business!, only: [:create, :update, :destroy]
      before_action :set_product, only: [:show, :update, :destroy]

      def index
        @products = Product.active.page(params[:page]).per(params[:per_page])
        render json: ActiveModel::Serializer::CollectionSerializer.new(
          @products,
          serializer: ProductSerializer,
          meta: pagination_meta(@products)
        )
      end

      def show
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
        @products = Product.search(params[:query]).page(params[:page]).per(params[:per_page])
        render json: ActiveModel::Serializer::CollectionSerializer.new(
          @products,
          serializer: ProductSerializer,
          meta: pagination_meta(@products)
        )
      end

      private

      def set_product
        @product = Product.find(params[:id])
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