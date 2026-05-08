require "rails_helper"

RSpec.describe "Api::V1::Auth::Passwords", type: :request do
  let(:password) { "SecurePassword123!" }
  let(:user)     { create(:user, password: password) }

  describe "POST /api/v1/auth/password/reset" do
    context "when the email is registered" do
      it "returns 200" do
        post "/api/v1/auth/password/reset", params: { email: user.email }

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to be_present
      end

      it "stores a reset token digest" do
        post "/api/v1/auth/password/reset", params: { email: user.email }

        expect(user.reload.reset_password_token_digest).not_to be_nil
      end
    end

    context "when the email is not registered" do
      it "returns 200 regardless" do
        post "/api/v1/auth/password/reset", params: { email: "nobody@example.com" }

        expect(response).to have_http_status(:ok)
      end

      it "returns the same message to avoid revealing account existence" do
        post "/api/v1/auth/password/reset", params: { email: user.email }
        registered_message = json_response[:message]

        post "/api/v1/auth/password/reset", params: { email: "nobody@example.com" }
        unregistered_message = json_response[:message]

        expect(registered_message).to eq(unregistered_message)
      end
    end

    context "when the email param is missing" do
      it "returns 400" do
        post "/api/v1/auth/password/reset"

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "PATCH /api/v1/auth/password/reset/confirm" do
    context "with a valid token" do
      it "returns 200 and updates the password" do
        raw_token = user.generate_reset_password_token!
        new_password = "NewSecurePass999!"

        patch "/api/v1/auth/password/reset/confirm",
              params: { token: raw_token, password: new_password }

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq("Password updated successfully")
        expect(user.reload.authenticate(new_password)).to be_truthy
      end

      it "revokes all refresh tokens" do
        raw_token = user.generate_reset_password_token!
        create(:refresh_token, user: user)
        create(:refresh_token, user: user)

        patch "/api/v1/auth/password/reset/confirm",
              params: { token: raw_token, password: "NewSecurePass999!" }

        expect(user.refresh_tokens.where(revoked_at: nil).count).to eq(0)
      end

      it "clears the reset token digest" do
        raw_token = user.generate_reset_password_token!

        patch "/api/v1/auth/password/reset/confirm",
              params: { token: raw_token, password: "NewSecurePass999!" }

        expect(user.reload.reset_password_token_digest).to be_nil
      end
    end

    context "with an expired token" do
      it "returns 422" do
        raw_token = user.generate_reset_password_token!
        user.update_columns(reset_password_sent_at: 2.hours.ago)

        patch "/api/v1/auth/password/reset/confirm",
              params: { token: raw_token, password: "NewSecurePass999!" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to eq("Reset token has expired")
      end
    end

    context "with an invalid token" do
      it "returns 422" do
        user.generate_reset_password_token!

        patch "/api/v1/auth/password/reset/confirm",
              params: { token: "not-a-real-token", password: "NewSecurePass999!" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to eq("Invalid reset token")
      end
    end

    context "with a password that is too short" do
      it "returns 422" do
        raw_token = user.generate_reset_password_token!

        patch "/api/v1/auth/password/reset/confirm",
              params: { token: raw_token, password: "short" }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when a required param is missing" do
      it "returns 400 when token is missing" do
        patch "/api/v1/auth/password/reset/confirm", params: { password: "NewSecurePass999!" }

        expect(response).to have_http_status(:bad_request)
      end

      it "returns 400 when password is missing" do
        raw_token = user.generate_reset_password_token!

        patch "/api/v1/auth/password/reset/confirm", params: { token: raw_token }

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
