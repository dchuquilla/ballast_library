class Book < ApplicationRecord
  has_many :book_copies, dependent: :destroy
  has_many :borrowings, through: :book_copies

  validates :title, :author, :genre, :isbn, presence: true
  validates :isbn, uniqueness: true
  validates :total_copies, numericality: { greater_than_or_equal_to: 0 }
end
