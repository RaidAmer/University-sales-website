class ChangeStatusToIntegerInCheckoutOrders < ActiveRecord::Migration[7.1]
  def change
    def change
      change_column :checkout_orders, :status, :integer, using: 'status::integer'
    end
  end
end
