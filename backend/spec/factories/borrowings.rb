FactoryBot.define do
  factory :borrowing do
    user { create(:user) }
    book_copy { create(:book_copy) }
    borrowed_at { DateTime.now }
    due_date { DateTime.now + 2.weeks }
    returned_at { nil }
  end
end
