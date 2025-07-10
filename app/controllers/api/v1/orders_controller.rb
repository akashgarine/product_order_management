module Api
  module V1
    class OrdersController < ApplicationController
      before_action :authenticate_user!, only: [:create]
      before_action :set_order, only: [:show, :cancel]

      def index
        @orders = current_user.orders.page(params[:page]).per(params[:per_page])
        render json: ActiveModel::Serializer::CollectionSerializer.new(
          @orders,
          serializer: OrderSerializer
        )
      end

      def show
        render json: OrderSerializer.new(@order)
      end

      def create
        @order = current_user.orders.build(order_params)
        if @order.save
          order_service = OrderService.new(@order)
          order_service.process_order
          render json: OrderSerializer.new(@order), status: :created
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def cancel
        if @order.cancel
          render json: OrderSerializer.new(@order)
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_order
        @order = Order.find(params[:id])
      end

      def order_params
        params.require(:order).permit(
          order_items_attributes: [:product_id, :quantity]
        )
      end

      def authenticate_user!
        unless current_user
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