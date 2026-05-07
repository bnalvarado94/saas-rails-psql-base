module Auth
  class RefreshService < ApplicationService
    Result = Data.define(:access_token, :refresh_token_raw, :user)

    class TokenReusedError < StandardError; end
    class TokenInvalidError < StandardError; end

    def initialize(raw_token:, request: nil)
      @raw_token = raw_token
      @request   = request
    end

    def call
      token_record = find_token!
      detect_reuse!(token_record)
      rotate(token_record)
    end

    private

    def find_token!
      RefreshToken.find_by_raw(@raw_token) ||
        raise(TokenInvalidError, "Refresh token not found")
    end

    def detect_reuse!(token_record)
      return if token_record.active?

      # Token was already used or revoked — potential theft. Revoke the entire family.
      token_record.revoke_family!
      raise TokenReusedError, "Refresh token already used"
    end

    def rotate(token_record)
      _new_record, new_raw = token_record.rotate!(request: @request)
      access_token = JwtService.encode({ user_id: token_record.user_id })
      Result.new(access_token: access_token, refresh_token_raw: new_raw, user: token_record.user)
    end
  end
end
