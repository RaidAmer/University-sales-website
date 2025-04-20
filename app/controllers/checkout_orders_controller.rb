# frozen_string_literal: true

class CheckoutOrdersController < ApplicationController
  def index

    @checkout_orders = current_user.checkout_orders.order(id: :desc)
    render :index
    
  end

  def show
    @checkout_order = CheckoutOrder.find(params[:id])
    render :show
  end
  
  def create
    cart = Cart.find_or_create_by(user_id: current_user.id)
    total_price = cart.cart_items.sum { |item| item.product.price * item.quantity }
  
    @checkout_order = CheckoutOrder.new(
      total_price: total_price,
      user_id: current_user.id,
      status: "Pending",
      order_date: DateTime.now
    )
  
    if @checkout_order.save
      cart.cart_items.where(checkout_order_id: nil).update_all(checkout_order_id: @checkout_order.id)
      redirect_to new_payment_transaction_path(checkout_order_id: @checkout_order.id)
    else
      flash.now[:error] = 'Checkout failed'
      redirect_to cart_path, alert: 'Checkout failed.'
    end
  end
  
end  