module Api
  module V1
    module Auth
      class RegistrationsController < ApplicationController
        include ActionController::Cookies
        include ErrorHandler

        COOKIE_NAME = "refresh_token"

        # POST /api/v1/auth/register
        def create
          result = ::Auth::RegisterService.call(
            email:      params.require(:email),
            password:   params.require(:password),
            first_name: params[:first_name],
            last_name:  params[:last_name],
            request:    request
          )

          set_refresh_cookie(result.refresh_token_raw)
          render json: session_response(result.access_token, result.user), status: :created
        end

        private

        def set_refresh_cookie(raw_token)
          cookies[COOKIE_NAME] = {
            value:     raw_token,
            httponly:  true,
            secure:    Rails.env.production?,
            same_site: :lax,
            expires:   RefreshToken::EXPIRY.from_now
          }
        end

        def session_response(access_token, user)
          {
            access_token: access_token,
            token_type:   "Bearer",
            expires_in:   JwtService::DEFAULT_TTL.to_i,
            user:         UserSerializer.serialize_user(user)
          }
        end
      end
    end
  end
end
