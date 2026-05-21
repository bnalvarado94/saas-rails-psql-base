module Auth
  class RequestPasswordResetService < ApplicationService
    def initialize(email:)
      @email = email.to_s.strip.downcase
    end

    def call
      user = User.find_by(email: @email)

      # Always perform a constant-time-equivalent path to prevent email enumeration
      # via response timing differences between existing and non-existing accounts.
      if user
        raw_token = user.generate_reset_password_token!
        UserMailer.reset_password_email(user, raw_token).deliver_later
      else
        BCrypt::Password.create(SecureRandom.hex)
      end
    end
  end
end
