class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false, unique: true
      t.string :password_digest, :string, nuull: false
      t.string :role, null: false, default: "member", limit: 20, index: true

      t.timestamps
    end
  end
end
