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
#  location               :string
#  public_profile         :boolean
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string
#  username               :string
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
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :checkout_orders
  has_many :products
  has_one_attached :avatar
  has_one_attached :banner
  has_one :preference

  def admin?
    uuid == "U00828281"
  end

  def seller?
    preference&.role == 'seller' || preference&.role == 'both'
  end

  def buyer?
    preference&.role == 'buyer' || preference&.role == 'both'
  end

  def profile_completed?
    bio.present? && avatar&.attached? && banner&.attached?
  end
end
