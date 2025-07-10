class CreateBusinesses < ActiveRecord::Migration[6.1]
  def change
    create_table :businesses do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :active, default: true
      t.string :business_type
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :businesses, :email, unique: true
  end
end