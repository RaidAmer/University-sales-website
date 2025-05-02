class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :authorize_admin!

  def approve
    @user.update(approved: true)
    Notification.create!(
      recipient: @user,
      actor: current_user,
      action: "approved your account",
      notifiable: @user,
      read: false
    )
    redirect_back fallback_location: rails_admin.show_path(model_name: 'user', id: @user.id), notice: "User approved."
  end

  def deny
    @user.update(approved: false)
    Notification.create!(
      recipient: @user,
      actor: current_user,
      action: "denied your account",
      notifiable: @user,
      read: false
    )
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
