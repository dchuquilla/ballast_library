require "rails_helper"

RSpec.describe DeleteBookService do
  let!(:book) { create(:book) }
  let!(:copies) { create_list(:book_copy, 3, book: book) }

  describe "#call" do
    context "when the book exists" do
      it "deletes the book and its copies successfully" do
        service = DeleteBookService.new(book.id)
        result = service.call

        expect(result[:success]).to be true
        expect(result[:message]).to eq("Book and its copies deleted successfully")
        expect(Book.find_by(id: book.id)).to be_nil
        expect(BookCopy.where(book_id: book.id)).to be_empty
      end
    end

    context "when the book does not exist" do
      it "returns an error" do
        service = DeleteBookService.new(-1)
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to eq("Book not found")
      end
    end
  end
end
