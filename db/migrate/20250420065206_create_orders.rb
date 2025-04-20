class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.float :total_price
      t.integer :status
      t.datetime :order_date

      t.timestamps
    end
  end
end
