# frozen_string_literal: true

class CheckoutOrdersController < ApplicationController
  before_action :set_order, only: [:show, :cancel, :mark_as_delivered, :destroy]

  def index
    @checkout_orders = current_user.checkout_orders.order(id: :desc)
    render :index
  end

  def show
    @checkout_order = CheckoutOrder.find(params[:id])
    @message = Message.new
    @messages = @checkout_order.messages.includes(:sender).order(created_at: :asc)
    render :show
  end

  def create
    cart = current_user.cart
    if cart.cart_items.empty?
      flash[:alert] = 'Your cart is empty.'
      redirect_to cart_path and return
    end


    total_price = cart.cart_items.sum { |item| item.product.price * item.quantity }

    @checkout_order = CheckoutOrder.new(
      total_price: total_price,
      user_id:     current_user.id,
      status:      'Pending',
      order_date:  DateTime.now
    )

    if @checkout_order.save
      cart.cart_items.where(checkout_order_id: nil).update_all(checkout_order_id: @checkout_order.id)

      product_names = cart.cart_items.includes(:product).map { |item| item.product&.name || 'Unnamed Item' }

      Notification.create!(
        recipient: cart.cart_items.first&.product&.user,
        actor: current_user,
        action: "purchased your item(s)",
        metadata: { product_names: product_names },
        notifiable: @checkout_order,
        read: false
      )

      flash[:notice] = 'Order successfully placed!'
      redirect_to new_payment_transaction_path(checkout_order_id: @checkout_order.id)
    else
      flash[:alert] = 'Checkout failed.'
      redirect_to cart_path
    end
  end

  def delivered
    @checkout_order = current_user.checkout_orders.find(params[:id])
    @checkout_order.update(status: 'Delivered')

    if (first_item = @checkout_order.cart_items.first) && first_item.product && first_item.product.user
      Notification.create!(
        recipient: @checkout_order.user,
        actor: first_item.product.user,
        action: 'marked your order as delivered',
        notifiable: @checkout_order
      )
    end

    flash[:notice] = 'Order successfully delivered.'
    redirect_to checkout_orders_path
  end

  def cancel
    @checkout_order = CheckoutOrder.find(params[:id])
    unless @checkout_order.user == current_user || @checkout_order.cart_items.first&.product&.user == current_user
      flash[:alert] = 'You are not authorized to cancel this order.'
      redirect_to checkout_orders_path and return
    end
    @checkout_order.update(status: 'Cancelled')

    seller = @checkout_order.cart_items.first&.product&.user
    if seller.present? && seller != current_user
      Notification.create!(
        recipient: seller,
        actor: current_user,
        action: "cancelled their order for #{@checkout_order.cart_items.first.product.name rescue 'a product'}",
        notifiable: @checkout_order,
        read: false
      )
    end

    Notification.create!(
      recipient: @checkout_order.user,
      actor: current_user,
      action: "cancelled an order you placed for #{@checkout_order.cart_items.first.product.name rescue 'a product'}",
      notifiable: @checkout_order,
      read: false
    )
    flash[:notice] = 'Order has been cancelled.'
    redirect_to checkout_orders_path
  end

  def mark_as_delivered
    @checkout_order = CheckoutOrder.find(params[:id])
    @checkout_order.update(status: "Delivered")

    Notification.create!(
      recipient: @checkout_order.user,
      actor: current_user,
      action: "Your order has been delivered",
      notifiable: @checkout_order
    )

    flash[:notice] = "Order marked as delivered."
    redirect_to checkout_order_path(@checkout_order)
  end

  def confirm_delivery
    @checkout_order = CheckoutOrder.find(params[:id])
    confirmed = params[:buyer_confirmed] == "1"

    if @checkout_order.update(buyer_confirmed: confirmed)
      seller = @checkout_order.cart_items.first&.product&.user
      if seller.present?
        Notification.create!(
          recipient: seller,
          actor: current_user,
          action: confirmed ? "confirmed delivery of the order" : "reported order as not delivered",
          notifiable: @checkout_order
        )
      end
      flash[:notice] = confirmed ? 'You confirmed delivery.' : 'You reported this order as not delivered.'
    else
      flash[:alert] = 'Failed to update delivery confirmation.'
    end
    redirect_to checkout_orders_path
  end

  # DELETE /checkout_orders/:id
  def destroy
    @checkout_order = current_user.checkout_orders.find(params[:id])
    @checkout_order.destroy
    redirect_to checkout_orders_path, notice: 'Order was successfully deleted.'
  end

  # DELETE /checkout_orders/clear_all
  def clear_all
    current_user.checkout_orders.destroy_all
    redirect_to checkout_orders_path, notice: 'All orders have been cleared.'
  end

  private

  def set_order
    order = CheckoutOrder.find(params[:id])
    is_buyer = order.user_id == current_user.id
    is_seller = order.cart_items.any? { |item| item.product&.user_id == current_user.id }

    if is_buyer || is_seller
      @order = order
    else
      redirect_to checkout_orders_path, alert: "You are not authorized to view this order."
    end
  end
end