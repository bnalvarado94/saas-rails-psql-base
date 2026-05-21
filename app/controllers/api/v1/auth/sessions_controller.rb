module Api
  module V1
    module Auth
      class SessionsController < ApplicationController
        include ActionController::Cookies
        include ErrorHandler

        COOKIE_NAME = "refresh_token"

        rescue_from ::Auth::RefreshService::TokenReusedError,
                    ::Auth::RefreshService::TokenInvalidError do
          delete_refresh_cookie
          render json: { error: "Unauthorized" }, status: :unauthorized
        end

        # POST /api/v1/auth/login
        def create
          result = ::Auth::LoginService.call(
            email: params.require(:email),
            password: params.require(:password),
            request: request
          )

          set_refresh_cookie(result.refresh_token_raw)
          render json: session_response(result.access_token, result.user), status: :created
        end

        # POST /api/v1/auth/refresh
        def refresh
          raw = cookies[COOKIE_NAME]
          return render json: { error: "Unauthorized" }, status: :unauthorized if raw.blank?

          result = ::Auth::RefreshService.call(raw_token: raw, request: request)

          set_refresh_cookie(result.refresh_token_raw)
          render json: session_response(result.access_token, result.user)
        end

        # DELETE /api/v1/auth/logout
        def destroy
          raw = cookies[COOKIE_NAME]
          ::Auth::LogoutService.call(raw_token: raw) if raw.present?
          delete_refresh_cookie
          head :no_content
        end

        private

        def set_refresh_cookie(raw_token)
          cookies[COOKIE_NAME] = {
            value: raw_token,
            httponly: true,
            secure: Rails.env.production?,
            same_site: :strict,
            expires: RefreshToken::EXPIRY.from_now
          }
        end

        def delete_refresh_cookie
          cookies.delete(COOKIE_NAME, same_site: :strict, secure: Rails.env.production?)
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
