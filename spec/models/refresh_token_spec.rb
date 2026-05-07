require "rails_helper"

RSpec.describe RefreshToken, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:token_digest) }
    it { is_expected.to validate_presence_of(:family_id) }
    it { is_expected.to validate_presence_of(:expires_at) }
  end

  describe ".generate_for" do
    let(:user) { create(:user) }

    it "returns a record and a raw token string" do
      record, raw = RefreshToken.generate_for(user: user)

      expect(record).to be_persisted
      expect(raw).to be_a(String).and have_attributes(length: 64)
    end

    it "stores a digest of the raw token, not the raw token itself" do
      record, raw = RefreshToken.generate_for(user: user)

      expect(record.token_digest).to eq(Digest::SHA256.hexdigest(raw))
      expect(record.token_digest).not_to eq(raw)
    end

    it "sets expiry 30 days from now" do
      record, _ = RefreshToken.generate_for(user: user)

      expect(record.expires_at).to be_within(5.seconds).of(30.days.from_now)
    end

    it "each call produces a unique family_id" do
      _, _ = RefreshToken.generate_for(user: user)
      record2, _ = RefreshToken.generate_for(user: user)

      expect(RefreshToken.pluck(:family_id).uniq.size).to eq(RefreshToken.count)
    end
  end

  describe ".find_by_raw" do
    it "finds the token by its raw value" do
      record, raw = RefreshToken.generate_for(user: create(:user))

      expect(RefreshToken.find_by_raw(raw)).to eq(record)
    end

    it "returns nil for an unknown raw value" do
      expect(RefreshToken.find_by_raw("nonexistent")).to be_nil
    end
  end

  describe "#active?" do
    it "is true for a fresh token" do
      token = create(:refresh_token)
      expect(token).to be_active
    end

    it "is false when used" do
      token = create(:refresh_token, :used)
      expect(token).not_to be_active
    end

    it "is false when revoked" do
      token = create(:refresh_token, :revoked)
      expect(token).not_to be_active
    end

    it "is false when expired" do
      token = create(:refresh_token, :expired)
      expect(token).not_to be_active
    end
  end

  describe "#rotate!" do
    let(:user)  { create(:user) }
    let(:token) { create(:refresh_token, user: user) }

    it "marks the current token as used" do
      token.rotate!
      expect(token.reload.used_at).to be_present
    end

    it "returns a new active token in the same family" do
      new_record, _ = token.rotate!

      expect(new_record).to be_persisted
      expect(new_record.family_id).to eq(token.family_id)
      expect(new_record).to be_active
    end

    it "returns a usable raw token" do
      new_record, raw = token.rotate!

      expect(RefreshToken.find_by_raw(raw)).to eq(new_record)
    end
  end

  describe "#revoke_family!" do
    let(:user)      { create(:user) }
    let(:family_id) { SecureRandom.uuid }

    it "revokes all tokens in the family" do
      tokens = create_list(:refresh_token, 3, user: user, family_id: family_id)

      tokens.first.revoke_family!

      tokens.each { |t| expect(t.reload.revoked_at).to be_present }
    end

    it "does not affect tokens from other families" do
      token       = create(:refresh_token, user: user, family_id: family_id)
      other_token = create(:refresh_token, user: user)

      token.revoke_family!

      expect(other_token.reload.revoked_at).to be_nil
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    it ".active excludes used, revoked, and expired tokens" do
      active  = create(:refresh_token, user: user)
      _used   = create(:refresh_token, :used, user: user)
      _rev    = create(:refresh_token, :revoked, user: user)
      _exp    = create(:refresh_token, :expired, user: user)

      expect(RefreshToken.active).to contain_exactly(active)
    end
  end
end
