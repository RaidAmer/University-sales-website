# frozen_string_literal: true

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def current_cart
    @current_cart ||= Cart.first
  end

  before_action :store_user_location!, if: :storable_location?
  before_action :set_notifications

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
end

  private

  def set_notifications
    @notifications = current_user.notifications.where(read: false).order(created_at: :desc).limit(5) if current_user
  end