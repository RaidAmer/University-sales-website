# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    if current_user
      @cart = current_user.cart || current_user.create_cart
      @cart_items = @cart.cart_items.where(checkout_order_id: nil).includes(:product)
      @total = @cart_items.sum { |item| item.quantity * item.product.price }.round(2)
    else
      redirect_to new_user_session_path, alert: "You need to sign in to view your cart."
    end
  end
end
