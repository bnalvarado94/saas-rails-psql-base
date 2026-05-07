module Auth
  class LoginService < ApplicationService
    Result = Data.define(:access_token, :refresh_token_raw, :user)

    def initialize(email:, password:, request: nil)
      @email    = email
      @password = password
      @request  = request
    end

    def call
      user = find_user
      verify_password!(user)
      # TODO: enforce confirmed_at once email verification flow exists
      issue_tokens(user)
    end

    private

    def find_user
      User.find_by(email: @email.to_s.strip.downcase) ||
        raise(ActiveRecord::RecordNotFound, "Invalid email or password")
    end

    def verify_password!(user)
      unless user.authenticate(@password)
        raise ActiveRecord::RecordNotFound, "Invalid email or password"
      end
    end

    def issue_tokens(user)
      access_token = JwtService.encode({ user_id: user.id })
      _record, refresh_token_raw = RefreshToken.generate_for(user: user, request: @request)
      Result.new(access_token: access_token, refresh_token_raw: refresh_token_raw, user: user)
    end
  end
end
