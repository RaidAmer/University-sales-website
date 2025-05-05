# frozen_string_literal: true

class CheckoutOrdersController < ApplicationController
  before_action :authenticate_user!

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
    Rails.logger.debug '=== Checkout Order Debug ==='
    Rails.logger.debug { "current_user: #{current_user&.id || 'nil'}" }
    Rails.logger.debug { "existing cart: #{current_user&.cart&.id || 'none'}" }

    cart = current_user.cart
    if cart.cart_items.empty?
      flash[:alert] = 'Your cart is empty.'
      redirect_to cart_path and return
    end

    total_price = cart.cart_items.sum { |item| item.product.price * item.quantity }

    @checkout_order = current_user.checkout_orders.build(
      total_price: total_price,
      status:      'Placed',
      order_date:  DateTime.now
    )

    if @checkout_order.save
      # Link cart items to the newly created order
      cart.cart_items.where(checkout_order_id: nil).update_all(checkout_order_id: @checkout_order.id)

      # Create notifications
      product_names = cart.cart_items.includes(:product).map { |item| item.product&.name || 'Unnamed Item' }
      Notification.create!(
        recipient:  cart.cart_items.first&.product&.user,
        actor:      current_user,
        action:     'purchased your item(s)',
        metadata:   { product_names: product_names },
        notifiable: @checkout_order,
        read:       false
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
        recipient:  @checkout_order.user,
        actor:      first_item.product.user,
        action:     'marked your order as delivered',
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
        recipient:  seller,
        actor:      current_user,
        action:     "cancelled their order for #{begin
          @checkout_order.cart_items.first.product.name
        rescue StandardError
          'a product'
        end}",
        notifiable: @checkout_order,
        read:       false
      )
    end

    Notification.create!(
      recipient:  @checkout_order.user,
      actor:      current_user,
      action:     "cancelled an order you placed for #{begin
        @checkout_order.cart_items.first.product.name
      rescue StandardError
        'a product'
      end}",
      notifiable: @checkout_order,
      read:       false
    )
    flash[:notice] = 'Order has been cancelled.'
    redirect_to checkout_orders_path
  end

  def mark_as_delivered
    @checkout_order = current_user.checkout_orders.find(params[:id])
    if @checkout_order.update(status: 'Delivered')
      flash[:notice] = 'Order marked as delivered.'
    else
      flash[:error] = 'There was an issue marking the order as delivered.'
    end
    redirect_to checkout_orders_path
  end

  def confirm_delivery
    @checkout_order = current_user.checkout_orders.find(params[:id])
    if @checkout_order.update(confirmed_delivery: true)
      flash[:notice] = 'Delivery confirmed!'
    else
      flash[:alert] = 'There was an issue confirming the delivery.'
    end
    redirect_to checkout_orders_path
  end

  def destroy
    @checkout_order = CheckoutOrder.find(params[:id])
    if @checkout_order.destroy
      flash[:notice] = 'Order successfully deleted.'
    else
      flash[:error] = 'There was an issue deleting the order.'
    end
    redirect_to checkout_orders_path
  end

  def clear_all
    current_user.checkout_orders.destroy_all
    flash[:notice] = 'All orders have been cleared.'
    redirect_to checkout_orders_path
  end
end
