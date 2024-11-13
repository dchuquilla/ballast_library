# frozen_string_literal: true

class DeleteBookService
  def initialize(book_id)
    @book_id = book_id
  end

  def call
    book = Book.find_by(id: @book_id)
    return { success: false, error: "Book not found" } unless book

    ActiveRecord::Base.transaction do
      book.book_copies.destroy_all

      if book.destroy
        { success: true, message: "Book and its copies deleted successfully" }
      else
        raise ActiveRecord::Rollback
      end
    end
  rescue
    { success: false, error: "Failed to delete book and its copies" }
  end
end
