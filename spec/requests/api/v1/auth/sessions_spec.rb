require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  let(:password) { "SecurePassword123!" }
  let(:user)     { create(:user, password: password) }

  describe "POST /api/v1/auth/login" do
    let(:valid_params) { { email: user.email, password: password } }

    context "with valid credentials" do
      it "returns 201 with an access token and user payload" do
        post "/api/v1/auth/login", params: valid_params

        expect(response).to have_http_status(:created)
        expect(json_response).to include(:access_token, :token_type, :expires_in, :user)
        expect(json_response[:token_type]).to eq("Bearer")
        expect(json_response[:expires_in]).to eq(900)
        expect(json_response[:user][:email]).to eq(user.email)
      end

      it "sets an HttpOnly refresh_token cookie" do
        post "/api/v1/auth/login", params: valid_params

        cookie = response.cookies["refresh_token"]
        expect(cookie).to be_present

        set_cookie_header = response.headers["Set-Cookie"]
        expect(set_cookie_header).to match(/HttpOnly/i)
      end

      it "creates a refresh token record in the database" do
        expect {
          post "/api/v1/auth/login", params: valid_params
        }.to change(RefreshToken, :count).by(1)
      end
    end

    context "with invalid credentials" do
      it "returns 404 for wrong password" do
        post "/api/v1/auth/login", params: { email: user.email, password: "wrong" }

        expect(response).to have_http_status(:not_found)
        expect(json_response[:error]).to eq("Invalid email or password")
      end

      it "returns 404 for unknown email" do
        post "/api/v1/auth/login", params: { email: "nobody@example.com", password: password }

        expect(response).to have_http_status(:not_found)
        expect(json_response[:error]).to eq("Invalid email or password")
      end

      it "returns the same error message for both cases (no user enumeration)" do
        wrong_password = post "/api/v1/auth/login", params: { email: user.email, password: "wrong" }
        msg1 = json_response[:error]

        unknown_email = post "/api/v1/auth/login", params: { email: "x@x.com", password: password }
        msg2 = json_response[:error]

        expect(msg1).to eq(msg2)
      end

      it "returns 400 when email param is missing" do
        post "/api/v1/auth/login", params: { password: password }

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "POST /api/v1/auth/refresh" do
    context "with a valid refresh token cookie" do
      before { post "/api/v1/auth/login", params: { email: user.email, password: password } }

      it "returns a new access token" do
        original_token = json_response[:access_token]

        post "/api/v1/auth/refresh"

        expect(response).to have_http_status(:ok)
        expect(json_response[:access_token]).to be_present
        expect(json_response[:access_token]).not_to eq(original_token)
      end

      it "rotates the refresh token cookie" do
        original_cookie = response.cookies["refresh_token"]

        post "/api/v1/auth/refresh"

        expect(response.cookies["refresh_token"]).to be_present
        expect(response.cookies["refresh_token"]).not_to eq(original_cookie)
      end

      it "invalidates the old refresh token after rotation" do
        old_cookie = response.cookies["refresh_token"]
        post "/api/v1/auth/refresh"

        # Manually set the old cookie and try to refresh again
        cookies["refresh_token"] = old_cookie
        post "/api/v1/auth/refresh"

        expect(response).to have_http_status(:unauthorized)
      end

      it "revokes the entire family when a reused token is detected" do
        old_cookie = response.cookies["refresh_token"]
        post "/api/v1/auth/refresh"

        family_size_before = RefreshToken.where(revoked_at: nil).count

        cookies["refresh_token"] = old_cookie
        post "/api/v1/auth/refresh"

        expect(RefreshToken.where(revoked_at: nil).count).to be < family_size_before
      end
    end

    context "without a refresh token cookie" do
      it "returns 401" do
        post "/api/v1/auth/refresh"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    context "when logged in" do
      before { post "/api/v1/auth/login", params: { email: user.email, password: password } }

      it "returns 204 no content" do
        delete "/api/v1/auth/logout"

        expect(response).to have_http_status(:no_content)
      end

      it "clears the refresh token cookie" do
        delete "/api/v1/auth/logout"

        expect(response.cookies["refresh_token"]).to be_blank
      end

      it "revokes the refresh token in the database" do
        delete "/api/v1/auth/logout"

        expect(RefreshToken.where(user: user).all? { |t| t.revoked_at.present? }).to be true
      end
    end

    context "without a cookie (already logged out)" do
      it "is idempotent — returns 204 without error" do
        delete "/api/v1/auth/logout"

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
