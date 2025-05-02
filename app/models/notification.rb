# == Schema Information
#
# Table name: notifications
#
#  id              :bigint           not null, primary key
#  action          :string
#  notifiable_type :string           not null
#  read            :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  actor_id        :bigint           not null
#  notifiable_id   :bigint           not null
#  recipient_id    :bigint           not null
#
# Indexes
#
#  index_notifications_on_actor_id      (actor_id)
#  index_notifications_on_notifiable    (notifiable_type,notifiable_id)
#  index_notifications_on_recipient_id  (recipient_id)
#
# Foreign Keys
#
#  fk_rails_...  (actor_id => users.id)
#  fk_rails_...  (recipient_id => users.id)
#
class Notification < ApplicationRecord
  belongs_to :actor, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  after_create_commit -> {
    broadcast_prepend_to "notifications", target: "notification-list"
    broadcast_update_to "notifications", target: "notification-count"
  }
end
