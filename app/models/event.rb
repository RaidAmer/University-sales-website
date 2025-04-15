# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id               :bigint           not null, primary key
#  capacity         :integer
#  date             :datetime
#  description      :text
#  event_name       :string
#  image            :string
#  location         :string
#  price            :float
#  registered_users :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Event < ApplicationRecord
  serialize :registered_users, Array, coder: YAML

  validates :event_name, :location, :date, :price, :capacity, presence: true
  validates :date, comparison: { greater_than_or_equal_to: Time.current }
  validates :price, numericality: { greater_than_or_equal_to: 0.00 }
  validates :capacity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  has_one_attached :image
end
