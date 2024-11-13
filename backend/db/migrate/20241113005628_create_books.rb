class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :genre, null: false
      t.string :isbn, null: false, unique: true
      t.integer :total_copies, default: 0

      t.timestamps
    end
  end
end
