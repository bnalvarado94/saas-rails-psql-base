FactoryBot.define do
  factory :user do
    email         { Faker::Internet.unique.email }
    password      { "SecurePassword123!" }
    first_name    { Faker::Name.first_name }
    last_name     { Faker::Name.last_name }
    confirmed_at  { nil }

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
