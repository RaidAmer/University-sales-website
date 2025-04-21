# frozen_string_literal: true

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
  serialize :registered_users, Array, coder: YAML

  validates :event_name, presence: true, uniqueness: true
  validates :location, :date, :price, :capacity, presence: true
  # For unknown reasons, Rails considers the current date as yesterday's date. To accommodate this,
  # I made it so that it accepts yesterday's date or after.
  validates :date, comparison: {
    greater_than_or_equal_to: Date.current,
    message:                  "You can't set a past date or current date!"
  }
  validates :price,
            numericality: { greater_than_or_equal_to: 0.00, message: "You can't set a negative number as the price!" }
  validates :capacity,
            numericality: { only_integer: true, greater_than_or_equal_to: 1,
message: 'You must have at least one person in the event!' }

  has_many :registrations, dependent: :destroy
  has_many :registered_users, through: :registrations, source: :user

  has_one_attached :image
  belongs_to :user
end
