class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book_copy

  validate :unique_borrowing_per_book_copy, on: :create

  before_create :set_borrowed_at, :set_due_date

  scope :due_today, -> { where(due_date: Date.today) }
  scope :overdue, -> { where("due_date < ?", Date.today) }
  scope :user_with_overdure_books, -> { overdue.distinct.count(:user_id) }
  scope :overdue_users, -> { User.where(id: overdue.distinct.pluck(:user_id)) }

  private

  def unique_borrowing_per_book_copy
    return true unless book_copy.present?

    if BookCopy.where(id: book_copy.id, status: BOOK_STATUSES[:borrowed]).exists?
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
