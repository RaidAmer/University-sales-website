# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    @cart = Cart.find_or_create_by(user_id: 1)
    @cart_items = @cart.cart_items.includes(:product)
    @total = @cart_items.sum { |item| item.quantity * item.product.price }.round(2)
  end
end
