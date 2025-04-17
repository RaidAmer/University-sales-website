# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  
  def current_cart
    @current_cart ||= Cart.first
  before_action :store_user_location!, if: :storable_location?

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
