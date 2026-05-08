FactoryBot.define do
  factory :user do
    email      { Faker::Internet.unique.email }
    password   { "SecurePassword123!" }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
