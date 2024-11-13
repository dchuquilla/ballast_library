require "rails_helper"

RSpec.describe DueDateCalculatorService, type: :service do
  describe "#call" do
    it "calculates the due date correctly" do
      start_date = Date.new(2023, 10, 1) # Example start date
      service = DueDateCalculatorService.new(start_date)
      due_date = service.call

      # reuse the same logic from the services :D
      expected_due_date = start_date
      14.times do
        expected_due_date += 1.day
        expected_due_date += 2.days if expected_due_date.saturday?
      end

      # dates should match ;)
      expect(due_date).to eq(expected_due_date)
    end
  end
end
