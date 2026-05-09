# Purpose: Base controller for all API v1 endpoints.
# Includes error handling and authentication concerns.
# All v1 controllers should inherit from this instead of ApplicationController.

module Api
  module V1
    class BaseController < ApplicationController
      include ErrorHandler
      include Authenticatable
      include Pundit::Authorization

      around_action :scan_for_n_plus_one if Rails.env.development?

      # GOTCHA: Every non-index action in a subclass MUST call `authorize <record>`
      # (or `skip_authorization` for public actions). Forgetting raises
      # Pundit::AuthorizationNotPerformedError at runtime — it will NOT fail silently.
      # See UsersController#show for the canonical pattern.
      #
      # NOTE: `if:` lambdas are used instead of `only:`/`except:` to avoid
      # Rails 7.1's raise_on_missing_callback_actions blowing up on subcontrollers
      # that don't define an index action.
      after_action :verify_authorized,    unless: -> { action_name == "index" }
      after_action :verify_policy_scoped, if:     -> { action_name == "index" }

      rescue_from Pundit::NotAuthorizedError, with: :forbidden

      private

      def forbidden
        render json: { error: "Forbidden" }, status: :forbidden
      end

      def scan_for_n_plus_one
        Prosopite.scan
        yield
      ensure
        Prosopite.finish
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
