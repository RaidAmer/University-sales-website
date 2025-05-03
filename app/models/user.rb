# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean
#  admin_note             :text
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
#  theme                  :string
#  username               :string
#  uuid                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  university_id          :string
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
  has_one_attached :university_id
  has_one :preference, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :sent_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :nullify
  has_many :messages_sent, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :messages_received, class_name: "Message", foreign_key: :recipient_id, dependent: :destroy
  before_create :set_default_approval

  def admin?
    uuid == "U00828281"
  end

  def denied?
    approved == false
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

  def approval_status
    return "Approved" if approved == true
    return "Denied" if approved == false
    "Pending"
  end

  private

  def set_default_approval
    self.approved = nil if approved.nil?
  end

  after_create_commit :notify_admin_of_new_account

  def notify_admin_of_new_account
    admin = User.find_by(admin: true)
    if admin
      Notification.create!(
        recipient: admin,
        actor: self,
        action: "signed up and is pending approval",
        notifiable: self,
        read: false
      )
    end

    ActionCable.server.broadcast("admin_notifications", {
      email: self.email,
      created_at: self.created_at.strftime("%b %d, %Y %H:%M")
    })
  end
end
