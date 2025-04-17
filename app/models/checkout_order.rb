# == Schema Information
#
# Table name: checkout_orders
#
#  id          :bigint           not null, primary key
#  order_date  :datetime
#  status      :string
#  total_price :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#
class CheckoutOrder < ApplicationRecord
end
