class AddBuyerConfirmedToCheckoutOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :checkout_orders, :buyer_confirmed, :boolean
  end
end
