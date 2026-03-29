# Purpose: Smoke test for the /up health check endpoint.
# Verifies the app boots and responds correctly — useful as a CI canary.

require "rails_helper"

RSpec.describe "Health Check", type: :request do
  describe "GET /up" do
    it "returns 200 OK when the application is healthy" do
      get "/up"
      expect(response).to have_http_status(:ok)
    end
  end
end
