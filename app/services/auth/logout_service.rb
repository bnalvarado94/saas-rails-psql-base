module Auth
  class LogoutService < ApplicationService
    def initialize(raw_token:)
      @raw_token = raw_token
    end

    def call
      token_record = RefreshToken.find_by_raw(@raw_token)
      token_record&.revoke_family!
      true
    end
  end
end
