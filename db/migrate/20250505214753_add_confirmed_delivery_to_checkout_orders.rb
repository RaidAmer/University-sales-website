class AddConfirmedDeliveryToCheckoutOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :checkout_orders, :confirmed_delivery, :boolean
  end
end
