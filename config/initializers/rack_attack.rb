# Purpose: Rate limiting and request throttling to protect against abuse.
# Uses Rack::Attack with Rails.cache as the backing store.
# Customize thresholds via environment variables for different deployment targets.

class Rack::Attack
  # Throttle all requests by IP (300 requests per 5 minutes)
  throttle("req/ip", limit: ENV.fetch("RACK_ATTACK_LIMIT", 300).to_i, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Throttle login attempts by IP (5 attempts per 20 seconds)
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/api/v1/auth/login" && req.post?
  end

  # Throttle login attempts by email (allow 5 per email per minute)
  throttle("logins/email", limit: 5, period: 60.seconds) do |req|
    if req.path == "/api/v1/auth/login" && req.post?
      # Normalize the email to prevent bypasses
      req.params.dig("email")&.downcase&.strip
    end
  end

  # Return rate limit headers so clients can self-regulate
  Rack::Attack.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    now = match_data[:epoch_time]

    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => (match_data[:period] - (now % match_data[:period])).to_s,
      "X-RateLimit-Limit" => match_data[:limit].to_s,
      "X-RateLimit-Remaining" => "0"
    }

    [ 429, headers, [ { error: "Rate limit exceeded. Retry later." }.to_json ] ]
  end
end
