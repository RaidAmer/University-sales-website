# frozen_string_literal: true

class CartItemsController < ApplicationController
  def create
    Rails.logger.debug "=== Add to Cart Debug ==="
    Rails.logger.debug "current_user: #{current_user&.id || 'nil'}"
    Rails.logger.debug "existing cart: #{current_user&.cart&.id || 'none'}"

    cart = current_user.cart || Cart.create(user_id: current_user.id)

    if cart.persisted?
      begin
        # Find the product to add to the cart
        product = Product.find(params[:product_id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Product not found."
        redirect_to root_path and return
      end

      # Find or initialize a CartItem for this product in the user's cart
      cart_item = cart.cart_items.find_or_initialize_by(product_id: params[:product_id])
      cart_item.quantity ||= 0
      cart_item.quantity += 1
      cart_item.checkout_order_id = nil

      # Save the CartItem and provide feedback
      if cart_item.save
        flash[:notice] = "Item added to cart successfully."
      else
        Rails.logger.error "CartItem save failed: #{cart_item.errors.full_messages.join(', ')}"
        flash[:error] = "There was an error adding the item to your cart."
      end
    else
      flash[:error] = "There was an error creating your cart."
    end

    redirect_to cart_path
  end

  def update_quantity
    cart_item = CartItem.find(params[:id])
    new_qty = params[:quantity].to_i

    if new_qty > 0
      if cart_item.update(quantity: new_qty)
        flash[:notice] = "Quantity updated successfully."
      else
        flash[:error] = "There was an error updating the quantity."
      end
    else
      if cart_item.destroy
        flash[:notice] = "Item removed from cart."
      else
        flash[:error] = "There was an error removing the item from your cart."
      end
    end

    redirect_to cart_path
  end

  def destroy
    cart_item = CartItem.find(params[:id])
    if cart_item.destroy
      flash[:notice] = "Item removed from cart."
    else
      flash[:error] = "There was an error removing the item from your cart."
    end
    redirect_to cart_path
  end
end
