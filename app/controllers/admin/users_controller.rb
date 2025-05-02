class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :authorize_admin!

  def approve
    @user.update(approved: true)

    message_sent = params[:admin_message].present?

    message = nil
    if message_sent
      message = Message.create!(
        sender: current_user,
        recipient: @user,
        body: params[:admin_message]
      )
    end

    Notification.create!(
      recipient: @user,
      actor: current_user,
      action: message_sent ? "approved your account and sent you a message" : "approved your account",
      notifiable: message_sent ? message : @user,
      read: false
    )

    NotificationsChannel.broadcast_to(
      @user,
      actor: current_user.email,
      action: "approved your account"
    )

    redirect_back fallback_location: rails_admin.show_path(model_name: 'user', id: @user.id), notice: "User approved and message sent."
  end

  def deny
    @user.update(approved: false)

    message_sent = params[:admin_message].present?

    message = nil
    if message_sent
      message = Message.create!(
        sender: current_user,
        recipient: @user,
        body: params[:admin_message]
      )
    end

    Notification.create!(
      recipient: @user,
      actor: current_user,
      action: message_sent ? "denied your account and sent you a message" : "denied your account",
      notifiable: message_sent ? message : @user,
      read: false
    )

    NotificationsChannel.broadcast_to(
      @user,
      actor: current_user.email,
      action: "denied your account"
    )

    redirect_back fallback_location: rails_admin.show_path(model_name: 'user', id: @user.id), notice: "User denied and message sent."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_admin!
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end
end