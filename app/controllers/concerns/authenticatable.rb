# Purpose: JWT authentication concern for API controllers.
# Include this in controllers that require authenticated access.
# Expects Authorization header with format: "Bearer <token>"
# Uses JWT_SECRET env var for token verification.

module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    token = extract_token
    raise JWT::DecodeError, "Missing token" if token.blank?

    decoded = JwtService.decode(token)
    @current_user = User.find(decoded[:user_id])
  rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound => e
    render json: { error: "Unauthorized: #{e.message}" }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def extract_token
    request.headers["Authorization"]&.split("Bearer ")&.last
  end
end
