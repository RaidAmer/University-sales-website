# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean
#  approved               :boolean
#  bio                    :text
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  uuid                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uuid                  (uuid) UNIQUE
#
# app/models/user.rb

# app/models/user.rb

class User < ApplicationRecord
  # Devise modules with UUID authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:uuid]

  # UUID-based login
  validates :uuid, presence: true, uniqueness: true

  validates :approved, inclusion: { in: [true, false] }

  has_one_attached :avatar

  def profile_completed?
    bio.present? && avatar.attached?
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    uuid = conditions.delete(:uuid)
    where(conditions).where(['uuid = :value', { value: uuid }]).first
  end

  # Disable email requirement
  def email_required?
    false
  end

  def will_save_change_to_email?
    false
  end
  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.approved ||= false
    self.admin ||= false
  end

  # Event registration.
  has_many :events
  has_many :registrations
  has_many :registered_events, through: :registrations, source: :event

  # Active Storage attachment
  has_one_attached :university_id

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, presence: true, on: :create
  validate :university_id_presence_unless_admin

  private

  def university_id_presence_unless_admin
    return if admin? # Skip if it's an admin user

    return if university_id.attached?

    errors.add(:university_id, 'must be uploaded')
  end
end
