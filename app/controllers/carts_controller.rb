# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    @cart = current_user.cart || current_user.create_cart
    @cart_items = @cart.cart_items.includes(:product)
    @total = @cart_items.sum { |item| item.quantity * item.product.price }.round(2)
  end
end
