# frozen_string_literal: true

class CheckoutOrdersController < ApplicationController
  def index
    @checkout_orders = CheckoutOrder.order(id: :desc)
    render :index
  end

  def show
    @checkout_order = CheckoutOrder.find(params[:id])
    render :show
  end
  
  def create
    @checkout_order = CheckoutOrder.new(
      total_price: params[:total_price],
      user_id:     params[:user_id],
      status:      "Pending",
      order_date:  DateTime.now
    )

    if @checkout_order.save
      cart = Cart.find_by(user_id: params[:user_id])
      cart.cart_items.where(checkout_order_id: nil).update_all(checkout_order_id: @checkout_order.id)
      redirect_to new_payment_transaction_path(checkout_order_id: @checkout_order.id)    
    else
      flash.now[:error] = 'Checkout failed'
      redirect_to cart_path, alert: 'Checkout failed.'
    end
  end
end
