# frozen_string_literal: true

class LibrarianDashboardPresenter
  def initialize
    @total_books = Book.count
    @total_borrowed_books = BookCopy.borrowed.count
    @books_due_today = Borrowing.due_today.count
    @total_overdues = Borrowing.overdue.count
    @members_with_overdue_books = Borrowing.overdue_users
  end

  def as_json
    {
      total_books: @total_books,
      total_borrowed_books: @total_borrowed_books,
      books_due_today: @books_due_today,
      total_overdues: @total_overdues,
      members_with_overdue_books: @members_with_overdue_books.to_json,
    }
  end
end
