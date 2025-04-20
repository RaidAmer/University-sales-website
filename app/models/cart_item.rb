# frozen_string_literal: true

# == Schema Information
#
# Table name: cart_items
#
#  id                :bigint           not null, primary key
#  quantity          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cart_id           :bigint           not null
#  checkout_order_id :bigint
#  product_id        :bigint           not null
#
# Indexes
#
#  index_cart_items_on_cart_id            (cart_id)
#  index_cart_items_on_checkout_order_id  (checkout_order_id)
#  index_cart_items_on_product_id         (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (cart_id => carts.id)
#  fk_rails_...  (checkout_order_id => checkout_orders.id)
#  fk_rails_...  (product_id => products.id)
#
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :checkout_orders, optional: true
end
