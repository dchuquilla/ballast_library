class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book_copy

  validate :unique_borrowing_per_user, on: :create

  before_create :set_borrowed_at, :set_due_date

  def unique_borrowing_per_user
    if Borrowing.where(user: user, returned_at: nil).exists?
      errors.add(:user, "already has an active borrowing")
    end
  end

  def set_borrowed_at
    self.borrowed_at = DateTime.now
  end

  def set_due_date
    self.due_date = calculate_due_date
  end

  private

  # Calculate the due date for a week days only
  def calculate_due_date
    due_date = DateTime.now
    14.times do
      due_date += 1.day
      due_date += 2.days if due_date.saturday?
    end
    due_date
  end
end
