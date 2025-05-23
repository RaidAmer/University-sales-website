# == Schema Information
#
# Table name: messages
#
#  id                :bigint           not null, primary key
#  body              :text
#  read              :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  checkout_order_id :integer
#  event_id          :bigint
#  recipient_id      :bigint           not null
#  sender_id         :bigint           not null
#
# Indexes
#
#  index_messages_on_recipient_id  (recipient_id)
#  index_messages_on_sender_id     (sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (sender_id => users.id)
#
class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :event, optional: true  # Add this line to associate Message with Event

  validates :body, presence: true
end
