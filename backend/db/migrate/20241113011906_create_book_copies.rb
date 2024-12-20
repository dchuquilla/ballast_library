class CreateBookCopies < ActiveRecord::Migration[7.0]
  def change
    create_table :book_copies do |t|
      t.references :book, null: false, foreign_key: true
      t.string :copy_code, null: false, unique: true
      t.string :status, null: false, default: BOOK_STATUSES[:available]

      t.timestamps
    end
  end
end
