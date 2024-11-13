class BookCopy < ApplicationRecord
  belongs_to :book
  has_one :borrowing

  validates :status, presence: true, inclusion: { in: BOOK_STATUSES.values }

  before_create :generate_copy_code
  after_create :update_book_total_copies
  after_destroy :update_book_total_copies

  scope :borrowed, -> { where(status: BOOK_STATUSES[:borrowed]) }
  scope :available, -> { where(status: BOOK_STATUSES[:available]) }

  private

  def generate_copy_code
    last_copy_number = BookCopy.where(book_id: book_id).count + 1
    self.copy_code = "#{book.isbn}-#{format("%03d", last_copy_number)}"
  end

  def update_book_total_copies
    book.update(total_copies: BookCopy.where(book_id: book_id).count)
  end
end
