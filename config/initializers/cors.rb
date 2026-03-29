# Purpose: Configure Cross-Origin Resource Sharing (CORS) for API access.
# ALLOWED_ORIGINS env var controls which domains can call this API.
# In production, set this to your frontend domain(s), comma-separated.
# Example: ALLOWED_ORIGINS=https://app.example.com,https://admin.example.com

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch("ALLOWED_ORIGINS", "http://localhost:3000").split(",").map(&:strip))

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization X-Request-Id],
      max_age: 600
  end
end
