require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /api/v1/auth/register" do
    let(:valid_params) do
      {
        email:      "newuser@example.com",
        password:   "SecurePassword123!",
        first_name: "Alice",
        last_name:  "Smith"
      }
    end

    context "with valid params" do
      it "returns 201 with access token, token_type, expires_in, and user" do
        post "/api/v1/auth/register", params: valid_params

        expect(response).to have_http_status(:created)
        expect(json_response).to include(:access_token, :token_type, :expires_in, :user)
        expect(json_response[:token_type]).to eq("Bearer")
        expect(json_response[:user][:email]).to eq("newuser@example.com")
      end

      it "sets an HttpOnly refresh_token cookie" do
        post "/api/v1/auth/register", params: valid_params

        expect(response.cookies["refresh_token"]).to be_present
        expect(response.headers["Set-Cookie"]).to match(/HttpOnly/i)
      end

      it "creates the user in the database" do
        expect {
          post "/api/v1/auth/register", params: valid_params
        }.to change(User, :count).by(1)
      end

      it "creates a refresh token record" do
        expect {
          post "/api/v1/auth/register", params: valid_params
        }.to change(RefreshToken, :count).by(1)
      end
    end

    context "with a duplicate email" do
      before { create(:user, email: "newuser@example.com") }

      it "returns 422" do
        post "/api/v1/auth/register", params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to be_present
      end
    end

    context "with a password shorter than 12 characters" do
      it "returns 422" do
        post "/api/v1/auth/register", params: valid_params.merge(password: "short")

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to be_present
      end
    end

    context "with an invalid email format" do
      it "returns 422" do
        post "/api/v1/auth/register", params: valid_params.merge(email: "not-an-email")

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to be_present
      end
    end
  end
end
