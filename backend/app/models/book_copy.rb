class BookCopy < ApplicationRecord
  belongs_to :book

  # validates :copy_code, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: BOOK_STATUSES.values }

  before_create :generate_copy_code

  def generate_copy_code
    last_copy_number = BookCopy.where(book_id: book_id).count + 1
    self.copy_code = "#{book.isbn}-#{format("%03d", last_copy_number)}"
  end
end
