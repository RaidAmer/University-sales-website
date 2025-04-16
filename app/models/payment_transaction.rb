# == Schema Information
#
# Table name: payment_transactions
#
#  id                :bigint           not null, primary key
#  amount            :float
#  method            :string
#  receipt           :string
#  success           :boolean
#  timestamp         :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  checkout_order_id :integer
#
class PaymentTransaction < ApplicationRecord
end
