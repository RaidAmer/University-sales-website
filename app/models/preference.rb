# == Schema Information
#
# Table name: preferences
#
#  id           :bigint           not null, primary key
#  pattern      :string
#  role         :string
#  show_welcome :boolean
#  theme        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_preferences_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Preference < ApplicationRecord
  belongs_to :user

  THEMES = ['light-theme', 'dark-theme', 'blue-theme', 'orange-theme']

  # Available background patterns
  PATTERNS = ['none', 'stripes', 'dots', 'grid']
end
