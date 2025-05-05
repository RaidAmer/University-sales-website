# frozen_string_literal: true

# == Schema Information
#
# Table name: carts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def checkout!(checkout_order)
    cart_items.where(checkout_order_id: nil).each do |item|
      Rails.logger.debug "Linking CartItem ##{item.id} to CheckoutOrder ##{checkout_order.id}"
      item.update!(checkout_order_id: checkout_order.id)
    end
  end
end
