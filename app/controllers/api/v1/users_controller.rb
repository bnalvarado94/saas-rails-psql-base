module Api
  module V1
    # Canonical example of a controller that satisfies BaseController's
    # verify_authorized contract. Every non-index action MUST call `authorize`
    # or Pundit::AuthorizationNotPerformedError will be raised at runtime.
    class UsersController < BaseController
      def show
        @user = User.find(params[:id])
        authorize @user
        render json: UserSerializer.new(@user).serializable_hash, status: :ok
      end
    end
  end
end
