FactoryBot.define do
  factory :borrowing do
    user { create(:user) }
    book_copy { create(:book_copy) }
    returned_at { nil }
  end
end
