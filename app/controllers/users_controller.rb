class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :authorize_admin!

  def approve
    @user.update(approved: true)
    if @user.present? && current_user.present?
      Notification.create!(
        recipient: @user,
        recipient_type: @user.class.name,
        actor: current_user,
        actor_type: current_user.class.name,
        action: "approved your account",
        notifiable: @user,
        notifiable_type: @user.class.name,
        read: false
      )
    end
    redirect_back fallback_location: rails_admin.show_path(model_name: 'user', id: @user.id), notice: "User approved."
  end

  def deny
    @user.update(approved: false)
    if @user.present? && current_user.present?
      Notification.create!(
        recipient: @user,
        recipient_type: @user.class.name,
        actor: current_user,
        actor_type: current_user.class.name,
        action: "denied your account",
        notifiable: @user,
        notifiable_type: @user.class.name,
        read: false
      )
    end
    redirect_back fallback_location: rails_admin.show_path(model_name: 'user', id: @user.id), alert: "User denied."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_admin!
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end
end

class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(user_params)
      redirect_to profile_path(current_user), notice: "Profile updated."
    else
      render :edit, alert: "Update failed."
    end
  end

  private

  def user_params
    params.require(:user).permit(:theme)
  end
end
