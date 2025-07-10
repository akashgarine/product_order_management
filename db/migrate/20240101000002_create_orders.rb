class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.decimal :total_amount, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end