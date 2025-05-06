# frozen_string_literal: true

class PaymentTransactionsController < ApplicationController
  def new
    @payment_transaction = PaymentTransaction.new
    @total = current_cart.cart_items.sum { |item| item.product.price * item.quantity } if current_cart.present?
    @cart_items = current_cart.present? ? current_cart.cart_items : []
    @payment_transaction = PaymentTransaction.new
  end

  def create
    @payment_transaction = PaymentTransaction.new(payment_params)
    @payment_transaction.timestamp = DateTime.now
    @payment_transaction.success = true

    unless ['Campus', 'Apple pay'].include?(payment_params[:method])
      card_valid = params[:card_number].present? &&
                   params[:expiration_date].present? &&
                   params[:cvv].present?

      unless card_valid
        flash.now[:error] = 'Please complete all card fields.'
        return render :new
      end
    end

    @checkout_order = CheckoutOrder.new(
      user: current_user,
      order_date: Time.zone.now,
      status: 'Placed'
    )

    # Associate cart items to the order
    if current_cart.present?
      current_cart.cart_items.where(checkout_order_id: nil).each do |item|
        item.checkout_order = @checkout_order
        item.save
      end
    end

    @checkout_order.save
    @payment_transaction.checkout_order = @checkout_order

    if @payment_transaction.save
      CartItem.where(cart_id: current_cart.id, checkout_order_id: nil).destroy_all if current_cart.present?
      flash[:notice] = 'Order successfully placed!'
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
