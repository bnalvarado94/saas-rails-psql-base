require "rails_helper"

RSpec.describe "Api::V1::Auth::Confirmations", type: :request do
  let(:password) { "SecurePassword123!" }
  let(:user)     { create(:user, :unconfirmed, password: password) }

  describe "POST /api/v1/auth/confirm" do
    context "with a valid token" do
      it "returns 200 and confirms the user" do
        raw_token = user.generate_confirmation_token!

        post "/api/v1/auth/confirm", params: { token: raw_token }

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq("Email confirmed successfully")
        expect(user.reload.confirmed_at).not_to be_nil
      end

      it "clears confirmation_token_digest after confirmation" do
        raw_token = user.generate_confirmation_token!

        post "/api/v1/auth/confirm", params: { token: raw_token }

        expect(user.reload.confirmation_token_digest).to be_nil
      end
    end

    context "with an expired token" do
      it "returns 422" do
        raw_token = user.generate_confirmation_token!
        user.update_columns(confirmation_sent_at: 25.hours.ago)

        post "/api/v1/auth/confirm", params: { token: raw_token }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to eq("Confirmation token has expired")
      end
    end

    context "with an invalid token" do
      it "returns 422" do
        user.generate_confirmation_token!

        post "/api/v1/auth/confirm", params: { token: "not-the-right-token" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to eq("Invalid confirmation token")
      end
    end

    context "when token param is missing" do
      it "returns 400" do
        post "/api/v1/auth/confirm"

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
