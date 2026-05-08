module Auth
  class RequestPasswordResetService < ApplicationService
    def initialize(email:)
      @email = email.to_s.strip.downcase
    end

    def call
      user = User.find_by(email: @email)
      return unless user

      raw_token = user.generate_reset_password_token!
      UserMailer.reset_password_email(user, raw_token).deliver_later
    end
  end
end
