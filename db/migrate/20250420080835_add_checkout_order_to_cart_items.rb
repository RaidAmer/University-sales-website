class AddCheckoutOrderToCartItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :cart_items, :checkout_order, null: false, foreign_key: true
  end
end
