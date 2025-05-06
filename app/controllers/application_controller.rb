# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Use current_user to get the cart for the logged-in user
  def current_cart
    @current_cart ||= current_user.cart || current_user.create_cart
  end

  before_action :store_user_location!, if: :storable_location?
  before_action :set_notifications
  before_action :check_approval_status

  # Check if the user is approved
  def check_approval_status
    if current_user && current_user.approved.nil? && request.path.start_with?("/products")
      flash.now[:alert] = "Access denied. Please wait until your account is approved by an admin."
    end
  end

  protected

  # Save the page the user was on
  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  # Conditions for when to store location
  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !request.xhr? &&
      !user_signed_in?
  end

  # After login, redirect them back to that page
  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end

  private

  # Set notifications for the current user
  def set_notifications
    @notifications = current_user.notifications.where(read: false).order(created_at: :desc).limit(5) if current_user
  end
end
