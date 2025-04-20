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

class User < ApplicationRecord
  attr_accessor :uuid_confirmation

  has_many(
    :products,
    class_name:  'Product',
    foreign_key: 'user_id',
    inverse_of:  :user,
    dependent:   :destroy
  )

  # Devise modules with UUID authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:uuid]

  # UUID-based login
  validates :uuid, presence: { message: "must be provided" }, confirmation: true, uniqueness: true
 
validates :approved, inclusion: { in: [true, false] }

has_one_attached :avatar

def profile_completed?
  bio.present? && avatar.attached?
end
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    uuid = conditions.delete(:uuid)
    where(conditions).where(["uuid = :value", { value: uuid }]).first
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
  
  # Active Storage attachment
  has_one_attached :university_id

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, presence: true, on: :create
  validate :university_id_presence_unless_admin
  validate :uuid_confirmation_matches_extracted_uuid

  private
  
    def university_id_presence_unless_admin
      return if admin? # Skip if it's an admin user
      unless university_id.attached?
      errors.add(:university_id, "must be uploaded")
      end
    end

    def uuid_confirmation_matches_extracted_uuid
      return if uuid_confirmation.blank? || university_id.blank?

      extracted_uuid = extract_uuid_from_uploaded_file
      if extracted_uuid.nil?
        errors.add(:university_id, "must be a valid file to extract UUID")
      elsif uuid_confirmation.strip != extracted_uuid.strip
        errors.add(:uuid_confirmation, "does not match the uploaded ID")
      end
    end

    def extract_uuid_from_uploaded_file
      return unless university_id.attached?
      tempfile = university_id.blob.service.send(:path_for, university_id.key)
      content = File.read(tempfile)
      content.match(/(U\d{7,})/)&. 
    rescue
      nil
    end
end