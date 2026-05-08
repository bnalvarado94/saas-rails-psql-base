module Api
  module V1
    module Auth
      class PasswordsController < ApplicationController
        include ErrorHandler

        rescue_from ::Auth::ResetPasswordService::InvalidTokenError do |e|
          render json: { error: e.message }, status: :unprocessable_entity
        end

        rescue_from ::Auth::ResetPasswordService::ExpiredTokenError do |e|
          render json: { error: e.message }, status: :unprocessable_entity
        end

        # POST /api/v1/auth/password/reset
        def create
          ::Auth::RequestPasswordResetService.call(email: params.require(:email))
          render json: { message: "If that email is registered, you will receive reset instructions shortly" },
                 status: :ok
        end

        # PATCH /api/v1/auth/password/reset/confirm
        def confirm
          ::Auth::ResetPasswordService.call(
            token:    params.require(:token),
            password: params.require(:password)
          )
          render json: { message: "Password updated successfully" }, status: :ok
        end
      end
    end
  end
end
