# Purpose: Base controller for all API v1 endpoints.
# Includes error handling and authentication concerns.
# All v1 controllers should inherit from this instead of ApplicationController.

module Api
  module V1
    class BaseController < ApplicationController
      include ErrorHandler
      include Authenticatable
      include Pundit::Authorization

      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      rescue_from Pundit::NotAuthorizedError, with: :forbidden

      private

      def forbidden
        render json: { error: "Forbidden" }, status: :forbidden
      end

      def paginate(scope, per_page: 25)
        limit = [ (params[:per_page] || per_page).to_i, 100 ].min
        pagy  = Pagy::Offset.new(count: scope.count, page: params[:page].to_i, limit: limit)
        meta  = {
          current_page: pagy.page,
          per_page:     pagy.limit,
          total_pages:  pagy.pages,
          total_count:  pagy.count
        }
        [ pagy.records(scope), meta ]
      end
    end
  end
end
