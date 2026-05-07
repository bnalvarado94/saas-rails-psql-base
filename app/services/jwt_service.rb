# Purpose: Encode and decode JWT access tokens for API authentication.
# Uses HS256 with JWT_SECRET env var (required in production).
# Default expiration: 15 minutes — intentionally short because JWTs cannot be revoked.

class JwtService
  ALGORITHM = "HS256"
  DEFAULT_TTL = 15.minutes

  def self.encode(payload, exp: nil)
    exp ||= DEFAULT_TTL.from_now
    payload = payload.merge(
      exp: exp.to_i,
      jti: SecureRandom.uuid
    )
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
    HashWithIndifferentAccess.new(decoded.first)
  end

  def self.secret_key
    ENV.fetch("JWT_SECRET") do
      raise KeyError, "JWT_SECRET env var is required in production" if Rails.env.production?
      Rails.application.secret_key_base
    end
  end
end
