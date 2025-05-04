# == Schema Information
#
# Table name: notifications
#
#  id              :bigint           not null, primary key
#  action          :string
#  actor_type      :string
#  metadata        :jsonb
#  notifiable_type :string
#  read            :boolean          default(FALSE), not null
#  recipient_type  :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  actor_id        :bigint
#  notifiable_id   :bigint
#  recipient_id    :bigint           not null
#
# Indexes
#
#  index_notifications_on_actor       (actor_type,actor_id)
#  index_notifications_on_notifiable  (notifiable_type,notifiable_id)
#  index_notifications_on_recipient   (recipient_type,recipient_id)
#
class Notification < ApplicationRecord
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :recipient, polymorphic: true
  belongs_to :notifiable, polymorphic: true

  # Checks if a notification with the same recipient, actor, action, and notifiable already exists
  def self.exists_for?(recipient:, actor:, action:, notifiable:)
    where(
      recipient: recipient,
      actor: actor,
      action: action,
      notifiable: notifiable
    ).exists?
  end

  after_create_commit -> {
    return if recipient.nil?

    user = User.find_by(id: recipient_id)
    # Check if the recipient is an event creator
    if recipient_type == "User" && user&.admin?
      broadcast_prepend_to "notifications", target: "notification-list"
      broadcast_update_to "notifications", target: "notification-count"
    elsif notifiable_type == "Event" && action == "registered for your event"
      # Handle the event creator's notification when someone registers
      broadcast_prepend_to "notifications", target: "event-creator-notifications"
    elsif notifiable_type == "Event" && action == "canceled your event"
      # Handle the event creator's notification when the event is canceled
      broadcast_prepend_to "notifications", target: "event-canceled-notifications"
    elsif notifiable_type == "Event" && action == "deleted an event you registered for"
      # Notify attendees that the event they registered for was deleted
      broadcast_prepend_to "notifications", target: "event-deleted-attendee-notifications"
    elsif notifiable_type == "Event" && action == "unregistered from your event"
      broadcast_prepend_to "notifications", target: "notification-list"
    elsif notifiable_type == "CheckoutOrder" && action.include?("cancelled their order")
      broadcast_prepend_to "notifications", target: "seller-notification-list"
    else
      broadcast_prepend_to "notifications", target: "notification-list"
      broadcast_update_to "notifications", target: "notification-count"
    end
  }
end
