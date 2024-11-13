class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book_copy

  validate :unique_borrowing_per_book_copy, on: :create

  before_create :set_borrowed_at, :set_due_date

  def unique_borrowing_per_book_copy
    if Borrowing.where(book_copy: book_copy, returned_at: nil).exists?
      errors.add(:book_copy, "is already borrowed")
    end
  end

  def set_borrowed_at
    self.borrowed_at = DateTime.now if self.borrowed_at.nil?
  end

  def set_due_date
    self.due_date = DueDateCalculatorService.new(DateTime.now).call if self.due_date.nil?
  end
end
