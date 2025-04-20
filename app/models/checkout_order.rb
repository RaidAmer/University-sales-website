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
  has_many :cart_items
  
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validates :order_date, presence: true
  validate :order_date_must_be_today

  private

  def order_date_must_be_today
    if order_date.present? && order_date.to_date != Date.current
      errors.add(:order_date, "must be today's date")
    end
  end
end
