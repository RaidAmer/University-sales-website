# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_reviews
#
#  id          :bigint           not null, primary key
#  description :text
#  rating      :integer
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  product_id  :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_customer_reviews_on_product_id  (product_id)
#  index_customer_reviews_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (user_id => users.id)
#
class CustomerReview < ApplicationRecord
  belongs_to(
    :product,
    class_name:  'Product',
    foreign_key: 'product_id',
    inverse_of:  :customer_reviews
  )

  belongs_to(
    :user,
    class_name:  'User',
    foreign_key: 'user_id',
    inverse_of:  :customer_reviews
  )

  validates :title, presence: true
  validates :description, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }
end
