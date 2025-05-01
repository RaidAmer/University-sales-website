# == Schema Information
#
# Table name: reviews
#
#  id                :bigint           not null, primary key
#  content           :text
#  rating            :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  checkout_order_id :bigint           not null
#
# Indexes
#
#  index_reviews_on_checkout_order_id  (checkout_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (checkout_order_id => checkout_orders.id)
#
class Review < ApplicationRecord
  belongs_to :checkout_order
end
