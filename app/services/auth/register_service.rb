module Auth
  class RegisterService < ApplicationService
    Result = Data.define(:access_token, :refresh_token_raw, :user)

    def initialize(email:, password:, first_name: nil, last_name: nil, request: nil)
      @email      = email
      @password   = password
      @first_name = first_name
      @last_name  = last_name
      @request    = request
    end

    def call
      user = User.create!(
        email:      @email,
        password:   @password,
        first_name: @first_name,
        last_name:  @last_name
      )
      send_confirmation_email(user)
      issue_tokens(user)
    end

    private

    def send_confirmation_email(user)
      raw_token = user.generate_confirmation_token!
      UserMailer.confirmation_email(user, raw_token).deliver_later
    end

    def issue_tokens(user)
      access_token = JwtService.encode({ user_id: user.id })
      _record, refresh_token_raw = RefreshToken.generate_for(user: user, request: @request)
      Result.new(access_token: access_token, refresh_token_raw: refresh_token_raw, user: user)
    end
  end
end
