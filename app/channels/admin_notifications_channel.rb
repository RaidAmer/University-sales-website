class AdminNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "admin_notifications" if current_user&.admin?
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
