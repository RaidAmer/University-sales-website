# frozen_string_literal: true

class PaymentTransactionsController < ApplicationController
  def new
    @checkout_order = CheckoutOrder.find_by(id: params[:checkout_order_id])

    unless @checkout_order
      redirect_to cart_path, alert: 'Invalid or missing order. Please try again.'
      return
    end

    @payment_transaction = PaymentTransaction.new
  end

  def create
    @payment_transaction = PaymentTransaction.new(payment_params)
    @payment_transaction.timestamp = DateTime.now
    @payment_transaction.success = true

    if @payment_transaction.save
      CartItem.where(cart_id: current_cart.id).destroy_all if current_cart.present?
      flash[:notice] = 'Payment Successful'
      redirect_to categories_path
    else
      flash.now[:error] = 'Payment Failed'
      render :new
    end
  end

  private

  def payment_params
    params.require(:payment_transaction).permit(:amount, :method, :receipt, :checkout_order_id)
  end
end
