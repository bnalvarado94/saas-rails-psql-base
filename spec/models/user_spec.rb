require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:refresh_tokens).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to have_secure_password }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:password).is_at_least(12) }

    it "rejects invalid email formats" do
      user = build(:user, email: "not-an-email")
      expect(user).not_to be_valid
    end
  end

  describe "email normalization" do
    it "downcases and strips email on save" do
      user = create(:user, email: "  JUAN@EXAMPLE.COM  ")
      expect(user.reload.email).to eq("juan@example.com")
    end

    it "finds by email regardless of case" do
      create(:user, email: "juan@example.com")
      expect(User.find_by(email: "JUAN@EXAMPLE.COM")).to be_present
    end
  end

  describe "scopes" do
    it ".confirmed returns only users with confirmed_at set" do
      confirmed   = create(:user, :confirmed)
      unconfirmed = create(:user)

      expect(User.confirmed).to include(confirmed)
      expect(User.confirmed).not_to include(unconfirmed)
    end
  end
end
