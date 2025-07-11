class AddUniqueIndexToBusinessesEmail < ActiveRecord::Migration[6.1]
  def change
    remove_index :businesses, :email if index_exists?(:businesses, :email)
    add_index :businesses, :email, unique: true
  end
end
