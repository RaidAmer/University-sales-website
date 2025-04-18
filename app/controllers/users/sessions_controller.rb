# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  def create
    # Try to find user by UUID
    user = User.find_by(uuid: params[:user][:uuid])

    if user.nil?
      flash[:alert] = "🚫 This student does not exist. Please create an account."
      redirect_to new_user_session_path and return
    end

    unless user.approved?
      flash[:alert] = "⏳ Your account has not been approved yet. Please wait for admin approval."
      redirect_to new_user_session_path and return
    end

    # Set Devise expected params
    params[:user][:email] = user.email if user.email.present?

    # Proceed with default Devise behavior
    super
  end

  protected

  # Permit UUID instead of email
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:uuid, :password])
  end
end
