# == Schema Information
#
# Table name: notifications
#
#  id              :bigint           not null, primary key
#  action          :string
#  actor_type      :string
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

  after_create_commit -> {
    broadcast_prepend_to "notifications", target: "notification-list"
    broadcast_update_to "notifications", target: "notification-count"
  }
end
