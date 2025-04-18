# frozen_string_literal: true

class CheckoutOrdersController < ApplicationController
  def create
    @checkout_order = CheckoutOrder.new(
      total_price: params[:total_price],
      user_id:     params[:user_id],
      status:      'Pending',
      order_date:  DateTime.now
    )

    if @checkout_order.save
      redirect_to new_payment_transaction_path(checkout_order_id: @checkout_order.id)
    else
      flash.now[:error] = 'Checkout failed'
      redirect_to cart_path, alert: 'Checkout failed.'
    end
  end
end
