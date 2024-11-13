# frozen_string_literal: true

class DueDateCalculatorService
  def initialize(start_date)
    @start_date = start_date
  end

  # Calculate the due date for a borrowing
  # 14 times/days = 2 weeks ;)
  def call
    due_date = @start_date
    14.times do
      due_date += 1.day
      due_date += 2.days if due_date.saturday?
    end
    due_date
  end
end
