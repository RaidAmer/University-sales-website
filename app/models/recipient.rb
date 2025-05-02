# == Schema Information
#
# Table name: recipients
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notification_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_recipients_on_notification_id  (notification_id)
#  index_recipients_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (notification_id => notifications.id)
#  fk_rails_...  (user_id => users.id)
#
class Recipient < ApplicationRecord
  belongs_to :user
  belongs_to :notification
end
