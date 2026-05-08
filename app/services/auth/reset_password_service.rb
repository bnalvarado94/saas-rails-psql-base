module Auth
  class ResetPasswordService < ApplicationService
    class InvalidTokenError < StandardError; end
    class ExpiredTokenError < StandardError; end

    def initialize(token:, password:)
      @token    = token.to_s
      @password = password
    end

    def call
      digest = Digest::SHA256.hexdigest(@token)
      user   = User.find_by(reset_password_token_digest: digest)

      raise InvalidTokenError, "Invalid reset token" unless user
      raise ExpiredTokenError, "Reset token has expired" if user.reset_password_expired?

      user.update!(
        password:                    @password,
        reset_password_token_digest: nil,
        reset_password_sent_at:      nil
      )
      user.refresh_tokens.update_all(revoked_at: Time.current)
      user
    end
  end
end
