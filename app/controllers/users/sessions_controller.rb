# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def create
    # Custom UUID lookup before Devise auth
    user = User.find_by(uuid: params[:user][:uuid])

    if user.nil?
      flash[:alert] = "This student does not exist. Please create account."
      redirect_to new_user_session_path and return
    end

    # Swap the UUID param to Devise's expected :email param
    # (only if you haven't removed :email from your User model)
    params[:user][:email] = user.email if user.email.present?

    # Now proceed with normal Devise authentication
    super
  end

  protected

  # Permit UUID instead of email during sign in
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:uuid, :password])
  end
end
