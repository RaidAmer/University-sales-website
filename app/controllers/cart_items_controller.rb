# frozen_string_literal: true

class CartItemsController < ApplicationController
  def create
    cart = Cart.find_or_create_by(user_id: 1)
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
