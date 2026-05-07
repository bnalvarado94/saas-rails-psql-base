FactoryBot.define do
  factory :refresh_token do
    association :user
    token_digest { Digest::SHA256.hexdigest(SecureRandom.hex(32)) }
    family_id    { SecureRandom.uuid }
    expires_at   { 30.days.from_now }
    used_at      { nil }
    revoked_at   { nil }

    trait :used do
      used_at { 1.hour.ago }
    end

    trait :revoked do
      revoked_at { 1.hour.ago }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end
  end
end
