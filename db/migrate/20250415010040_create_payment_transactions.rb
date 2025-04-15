class CreatePaymentTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_transactions do |t|
      t.float :amount
      t.string :method
      t.boolean :success
      t.datetime :timestamp
      t.string :receipt
      t.integer :checkout_order_id

      t.timestamps
    end
  end
end
