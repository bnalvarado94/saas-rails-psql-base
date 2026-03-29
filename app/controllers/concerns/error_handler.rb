# Purpose: Centralized error handling for API controllers.
# Rescues common exceptions and returns consistent JSON error responses.
# Include in Api::V1::BaseController to apply to all API endpoints.

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { error: e.message, details: e.record.errors }, status: :unprocessable_entity
    end

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message }, status: :bad_request
    end

    rescue_from JWT::DecodeError, JWT::ExpiredSignature do |e|
      render json: { error: "Unauthorized: #{e.message}" }, status: :unauthorized
    end
  end
end
