class AddCheckoutOrderIdToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :checkout_order_id, :integer
  end
end
