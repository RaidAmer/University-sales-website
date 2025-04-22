class ChangeCheckoutOrderIdToBeNullableInCartItems < ActiveRecord::Migration[7.1]
  def change
    change_column_null :cart_items, :checkout_order_id, true
  end
end
