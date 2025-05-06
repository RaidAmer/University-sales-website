# == Schema Information
#
# Table name: events
#
#  id               :bigint           not null, primary key
#  capacity         :integer
#  date             :date
#  description      :text
#  event_name       :string
#  image            :string
#  location         :string
#  price            :float
#  registered_users :text
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint
#
# Indexes
#
#  index_events_on_event_name  (event_name) UNIQUE
#  index_events_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Event < ApplicationRecord
  belongs_to :user
  has_many :messages
  has_one_attached :image
  has_many :registrations, dependent: :destroy
  has_many :registered_users, through: :registrations, source: :user
  # Add other associations or validations as needed
end
