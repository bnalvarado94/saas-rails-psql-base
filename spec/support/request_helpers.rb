# Purpose: Helper methods for request specs.
# Provides json_response parser, auth_headers for JWT bearer tokens,
# and set_refresh_cookie for endpoints that require a valid refresh token cookie.

module RequestHelpers
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  def auth_headers(user)
    token = JwtService.encode({ user_id: user.id })
    { "Authorization" => "Bearer #{token}" }
  end

  # Sets a valid refresh token cookie for the given user in the test session.
  # Use this in specs that test endpoints requiring a refresh_token cookie.
  def set_refresh_cookie(user)
    _, raw = RefreshToken.generate_for(user: user)
    cookies["refresh_token"] = raw
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
