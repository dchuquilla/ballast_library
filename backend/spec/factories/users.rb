require "faker"

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    role { "member" }

    trait :librarian do
      role { "librarian" }
    end
  end
end
