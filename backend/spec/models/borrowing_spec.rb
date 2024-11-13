require "rails_helper"

RSpec.describe Borrowing, type: :model do
  it "is valid with a due date" do
    borrowing = FactoryBot.create(:borrowing)
    expect(borrowing).to be_valid
    expect(borrowing.borrowed_at).to_not be_nil
    expect(borrowing.due_date).to_not be_nil
  end
end
