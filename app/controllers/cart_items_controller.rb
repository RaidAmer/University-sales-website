# frozen_string_literal: true

class CartItemsController < ApplicationController
  def create
    cart = current_user.cart || Cart.create(user_id: current_user.id)
    product = Product.find(params[:product_id])
    cart_item = cart.cart_items.find_or_initialize_by(product: product)
    cart_item.quantity ||= 0
    cart_item.quantity += 1
    cart_item.save
    redirect_to cart_path
  end

  def update_quantity
    cart_item = CartItem.find(params[:id])
    new_qty   = params[:quantity].to_i

    if new_qty > 0
      cart_item.update(quantity: new_qty)
    else
      cart_item.destroy
    end

    redirect_to cart_path
  end

  def destroy
    cart_item = CartItem.find(params[:id])
    cart_item.destroy
    redirect_to cart_path
  end
end
