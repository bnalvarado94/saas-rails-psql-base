module Auth
  class ConfirmEmailService < ApplicationService
    class InvalidTokenError < StandardError; end
    class ExpiredTokenError < StandardError; end

    def initialize(token:)
      @token = token.to_s
    end

    def call
      digest = Digest::SHA256.hexdigest(@token)
      user   = User.find_by(confirmation_token_digest: digest)

      raise InvalidTokenError, "Invalid confirmation token" unless user
      raise ExpiredTokenError, "Confirmation token has expired" if user.confirmation_expired?

      user.update!(
        confirmed_at: Time.current,
        confirmation_token_digest: nil,
        confirmation_sent_at: nil
      )

      user
    end
  end
end
