# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def current_cart
    @current_cart ||= Cart.first
  end
end
