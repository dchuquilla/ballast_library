FactoryBot.define do
  factory :book_copy do
    book { create(:book) }
    status { BOOK_STATUSES[:available] }
  end

  trait :borrowed do
    status { BOOK_STATUSES[:borrowed] }
  end
end
