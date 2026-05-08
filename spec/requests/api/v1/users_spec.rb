require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  let(:user)  { create(:user, :confirmed) }
  let(:other) { create(:user, :confirmed) }

  describe "GET /api/v1/users/:id" do
    context "when authenticated as the requested user" do
      it "returns 200 with the user payload" do
        get "/api/v1/users/#{user.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        data = json_response.dig(:data, :attributes)
        expect(data[:email]).to eq(user.email)
      end
    end

    context "when authenticated as a different user" do
      it "returns 403" do
        get "/api/v1/users/#{user.id}", headers: auth_headers(other)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without an auth token" do
      it "returns 401" do
        get "/api/v1/users/#{user.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
