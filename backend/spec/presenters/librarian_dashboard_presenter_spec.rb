require "rails_helper"

RSpec.describe LibrarianDashboardPresenter, type: :presenter do
  describe "#as_json" do
    before do
      allow(Book).to receive(:count).and_return(100)
      allow(BookCopy).to receive_message_chain(:borrowed, :count).and_return(50)
      allow(Borrowing).to receive_message_chain(:due_today, :count).and_return(5)
      allow(Borrowing).to receive_message_chain(:overdue, :count).and_return(10)
      allow(Borrowing).to receive(:overdue_users).and_return(["User1", "User2"])
    end

    it "returns the correct JSON representation" do
      presenter = LibrarianDashboardPresenter.new
      expected_json = {
        total_books: 100,
        total_borrowed_books: 50,
        books_due_today: 5,
        total_overdues: 10,
        members_with_overdue_books: '["User1","User2"]',
      }.to_json

      expect(presenter.as_json.to_json).to eq(expected_json)
    end
  end
end
