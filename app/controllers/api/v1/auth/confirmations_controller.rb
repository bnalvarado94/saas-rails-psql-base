module Api
  module V1
    module Auth
      class ConfirmationsController < ApplicationController
        include ErrorHandler

        rescue_from ::Auth::ConfirmEmailService::InvalidTokenError do |e|
          render json: { error: e.message }, status: :unprocessable_entity
        end

        rescue_from ::Auth::ConfirmEmailService::ExpiredTokenError do |e|
          render json: { error: e.message }, status: :unprocessable_entity
        end

        # POST /api/v1/auth/confirm
        def create
          ::Auth::ConfirmEmailService.call(token: params.require(:token))
          render json: { message: "Email confirmed successfully" }, status: :ok
        end
      end
    end
  end
end
