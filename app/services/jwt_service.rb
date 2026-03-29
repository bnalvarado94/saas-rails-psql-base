# Purpose: Encode and decode JWT tokens for API authentication.
# Uses HS256 algorithm with JWT_SECRET env var.
# Default expiration: 24 hours (configurable via JWT_EXPIRATION_HOURS).

class JwtService
  ALGORITHM = "HS256"

  def self.encode(payload, exp: nil)
    exp ||= ENV.fetch("JWT_EXPIRATION_HOURS", 24).to_i.hours.from_now
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
    HashWithIndifferentAccess.new(decoded.first)
  end

  def self.secret_key
    ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
  end
end
