require "rails_helper"

RSpec.describe BookCopy, type: :model do
  it "is valid with valid attributes" do
    book = FactoryBot.create(:book)
    book_copy = FactoryBot.create(:book_copy, book: book)
    expect(book_copy).to be_valid
  end

  it "is not valid without a book" do
    book_copy = FactoryBot.build(:book_copy, book: nil)
    expect(book_copy).not_to be_valid
  end
end
