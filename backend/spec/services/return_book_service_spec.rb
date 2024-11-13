require "rails_helper"

RSpec.describe ReturnBookService do
  let(:borrowing) { create(:borrowing) }
  let(:service) { described_class.new(borrowing) }

  describe "#call" do
    context "when the borrowing is successfully updated" do
      it "returns success and the borrowing" do
        allow(borrowing).to receive(:update).and_return(true)
        result = service.call

        expect(result[:success]).to be true
        expect(result[:borrowing]).to eq(borrowing)
        expect(borrowing.book_copy.status).to eq(BOOK_STATUSES[:available])
      end
    end

    context "when the borrowing update fails" do
      it "returns failure and errors" do
        allow(borrowing).to receive(:update).and_return(false)
        allow(borrowing).to receive_message_chain(:errors, :full_messages).and_return(["Error message"])
        result = service.call

        expect(result[:success]).to be false
        expect(result[:errors]).to eq(["Error message"])
        expect(borrowing.book_copy.status).to eq(BOOK_STATUSES[:borrowed])
      end
    end
  end
end
