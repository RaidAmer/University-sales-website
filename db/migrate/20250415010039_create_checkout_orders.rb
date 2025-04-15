class CreateCheckoutOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :checkout_orders do |t|
      t.float :total_price
      t.string :status
      t.datetime :order_date
      t.integer :user_id

      t.timestamps
    end
  end
end
