require "rails_helper"

RSpec.describe BorrowBookService do
  let(:user) { create(:user) }
  let(:book_copy) { create(:book_copy) }
  let(:params) { { book_copy_id: book_copy.id } }
  let(:service) { described_class.new(user, params) }

  describe "#call" do
    context "when borrowing is successful" do
      it "returns success message" do
        result = service.call
        expect(result[:success]).to be true
        expect(result[:message]).to eq("Book borrowed successfully")
        expect(Borrowing.last.user).to eq(user)
        expect(Borrowing.last.borrowed_at.to_date).to eq(Time.zone.now.to_date)
        expect(Borrowing.last.due_date.to_date).to eq(DueDateCalculatorService.new(Borrowing.last.borrowed_at).call.to_date)
      end
    end

    context "when borrowing fails" do
      before do
        allow_any_instance_of(Borrowing).to receive(:save).and_return(false)
        allow_any_instance_of(Borrowing).to receive_message_chain(:errors, :full_messages).and_return(["Error message"])
      end

      it "returns error messages" do
        result = service.call
        expect(result[:success]).to be false
        expect(result[:errors]).to include("Error message")
      end
    end
  end
end