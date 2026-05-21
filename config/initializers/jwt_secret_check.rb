# Fail fast at boot if JWT_SECRET is not set in production.
# Without this, the app starts successfully but crashes on the first login attempt.
raise "JWT_SECRET env var is required in production" if Rails.env.production? && ENV["JWT_SECRET"].blank?
