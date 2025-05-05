# frozen_string_literal: true

class CheckoutOrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @buyer_orders = current_user.checkout_orders
    @seller_orders = CheckoutOrder
                      .joins(cart_items: :product)
                      .where(products: { user_id: current_user.id })
                      .distinct
  end
  def show
    @checkout_order = CheckoutOrder.find(params[:id])
    @cart_items = CartItem.where(checkout_order_id: @checkout_order.id).includes(:product)
    @total = @cart_items.sum { |item| item.quantity * item.product.price }
    @message = Message.new
    @messages = @checkout_order.messages.includes(:sender).order(created_at: :asc)
    render :show
  end

  def create
    Rails.logger.debug '=== Checkout Order Debug ==='
    Rails.logger.debug { "current_user: #{current_user&.id || 'nil'}" }
    Rails.logger.debug { "existing cart: #{current_user&.cart&.id || 'none'}" }

    cart = current_user.cart
    unchecked_items = cart.cart_items.where(checkout_order_id: nil)
    Rails.logger.debug "==== CartItem Count in Cart: #{cart.cart_items.count}"
    Rails.logger.debug "==== CartItem IDs: #{cart.cart_items.pluck(:id)}"
    Rails.logger.debug "==== CartItem checkout_order_ids: #{cart.cart_items.pluck(:checkout_order_id)}"

    if unchecked_items.empty?
      flash[:alert] = 'Your cart is empty.'
      redirect_to cart_path and return
    end

    unchecked_items = unchecked_items.includes(:product).select { |item| item.product.present? }
    if unchecked_items.empty?
      flash[:alert] = 'Cart items are no longer available.'
      redirect_to cart_path and return
    end

    total_price = unchecked_items.sum { |item| item.product.price * item.quantity }

    @checkout_order = current_user.checkout_orders.build(
      total_price: total_price,
      status:      'Placed',
      order_date:  DateTime.now
    )

    begin
      CheckoutOrder.transaction do

        Rails.logger.debug "Cart items before linking to order:"
        unchecked_items.each do |item|
          Rails.logger.debug "  - CartItem ID: #{item.id}, Product ID: #{item.product_id}"
        end

        Rails.logger.debug "Linking CartItems #{unchecked_items.pluck(:id)} to CheckoutOrder (unsaved)"
        @checkout_order.save!

        unchecked_items.each do |item|
          item.update!(checkout_order_id: @checkout_order.id)
        end

        Rails.logger.debug "Checkout order saved successfully with ID: #{@checkout_order.id}"

        Rails.logger.debug "==== After update, linked CartItems:"
        Rails.logger.debug { CartItem.where(checkout_order_id: @checkout_order.id).pluck(:id, :checkout_order_id).inspect }

        product_names = unchecked_items.map { |item| item.product&.name || 'Unnamed Item' }
        Notification.create!(
          recipient:  unchecked_items.first&.product&.user,
          actor:      current_user,
          action:     'purchased your item(s)',
          metadata:   { product_names: product_names },
          notifiable: @checkout_order,
          read:       false
        )

        flash[:notice] = 'Order successfully placed!'
        redirect_to new_payment_transaction_path(checkout_order_id: @checkout_order.id) and return
      end
    rescue => e
      Rails.logger.debug "Checkout failed due to: #{e.message}"
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
    flash[:notice] = "Successfully cancelled Order ##{@checkout_order.id}."
    redirect_to checkout_orders_path
  end

  def mark_as_delivered
    @checkout_order = CheckoutOrder.includes(cart_items: :product).find(params[:id])
    authorized_seller = @checkout_order.cart_items.any? do |item|
      item.product&.user_id == current_user.id
    end

    unless authorized_seller
      flash[:alert] = "You are not authorized to mark this order as delivered. Only the product's seller can do this."
      redirect_to checkout_orders_path and return
    end

    if @checkout_order.update(status: 'Delivered')
      buyer = @checkout_order.user
      seller = @checkout_order.cart_items.first&.product&.user
      product_name = @checkout_order.cart_items.first&.product&.name || 'your product'

      Notification.create!(
        recipient:  buyer,
        actor:      seller,
        action:     "marked your order for #{product_name} as delivered",
        notifiable: @checkout_order,
        read:       false
      )

      flash[:notice] = "Successfully marked Order ##{@checkout_order.id} as delivered."
    else
      flash[:alert] = 'Failed to update the order status to delivered.'
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
