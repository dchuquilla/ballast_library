class AddSearBookIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :books, :title
    add_index :books, :author
    add_index :books, :genre
    add_index :books, :isbn
  end
end
