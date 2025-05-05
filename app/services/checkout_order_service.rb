class CheckoutOrderService
    def self.create_for(user)
      cart = user.cart
      return nil if cart.cart_items.empty?
  
      total_price = cart.cart_items.sum { |item| item.product.price * item.quantity }
  
      order = user.checkout_orders.build(
        total_price: total_price,
        status:      'Placed',
        order_date:  DateTime.now
      )
  
      if order.save
        cart.checkout!(order)
        order
      else
        nil
      end
    end
  endr