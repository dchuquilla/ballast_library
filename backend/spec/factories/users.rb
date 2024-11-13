require "faker"

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    role { APP_ROLES[:member] }

    trait :librarian do
      role { APP_ROLES[:librarian] }
    end
  end
end
