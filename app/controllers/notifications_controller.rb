class NotificationsController < ApplicationController
  def index
    return redirect_to root_path if current_user.admin?

    base_scope = current_user.notifications

    # Filter out system/admin-only messages for non-admins
    unless current_user.admin?
      base_scope = base_scope.where.not(notifiable_type: "User").or(
        base_scope.where(action: ["approved your account", "denied your account"])
      )
    end

    # ✅ Now mark only the visible unread notifications as read
    @unread_count = base_scope.where(read: [false, nil]).count
    base_scope.where(read: [false, nil]).update_all(read: true)

    @notifications =
      case params[:status]
      when "unread"
        base_scope.where(read: [false, nil]).order(created_at: :desc).limit(20)
      when "read"
        base_scope.where(read: true).order(created_at: :desc).limit(20)
      else
        base_scope.order(created_at: :desc).limit(20)
      end
  end
  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy
    redirect_to notifications_path, notice: "Notification deleted."
  end

  def mark_all_as_read
    current_user.notifications.where(read: [false, nil]).update_all(read: true)
    render json: { status: "success", message: "All notifications marked as read." }, status: :ok
  end

  def clear_all
    current_user.notifications.destroy_all
    redirect_to notifications_path, notice: "All notifications cleared."
  end
end
