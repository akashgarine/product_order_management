module Api
  module V1
    class BusinessAuthController < ApplicationController
      skip_before_action :authenticate_request!

      def login
        business = Business.find_by(email: params[:email])
        if business&.authenticate(params[:password])
          token = JsonWebToken.encode(business_id: business.id)
          render json: { token: token, business: BusinessSerializer.new(business) }, status: :ok
        else
          render json: { errors: ['Invalid email or password'] }, status: :unauthorized
        end
      end

      def signup
        business = Business.new(business_params)
        if business.save
          token = JsonWebToken.encode(business_id: business.id)
          render json: { token: token, business: BusinessSerializer.new(business) }, status: :created
        else
          render json: { errors: business.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def business_params
        params.require(:business).permit(:name, :email, :password, :password_confirmation, :business_type)
      end
    end
  end
end