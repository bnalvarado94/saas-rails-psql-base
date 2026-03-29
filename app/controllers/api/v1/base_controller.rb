# Purpose: Base controller for all API v1 endpoints.
# Includes error handling and authentication concerns.
# All v1 controllers should inherit from this instead of ApplicationController.

module Api
  module V1
    class BaseController < ApplicationController
      include ErrorHandler
      include Authenticatable

      private

      # Pagination helper — works with any ActiveRecord scope.
      # Returns [records, pagination_meta] for consistent paginated responses.
      # Uses simple offset pagination. Add kaminari or pagy for total_count/total_pages.
      def paginate(scope, per_page: 25)
        page = (params[:page] || 1).to_i.clamp(1, Float::INFINITY)
        per = (params[:per_page] || per_page).to_i.clamp(1, 100)
        offset = (page - 1) * per
        [ scope.limit(per).offset(offset), { current_page: page, per_page: per } ]
      end
    end
  end
end
