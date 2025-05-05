# frozen_string_literal: true

# == Schema Information
#
# Table name: checkout_orders
#
#  id              :bigint           not null, primary key
#  buyer_confirmed :boolean
#  order_date      :datetime
#  status          :string
#  total_price     :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
class CheckoutOrder < ApplicationRecord
  belongs_to :user
  has_many :order_items,
           class_name: "CartItem",
           foreign_key: "checkout_order_id",
           dependent: :destroy
  has_many :cart_items, foreign_key: "checkout_order_id"
  has_many :messages, dependent: :destroy

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validates :order_date, presence: true
  validate :order_date_must_be_today

  validate :all_items_must_have_sellers

  def all_items_must_have_sellers
    cart_items.each do |item|
      if item.product.nil? || item.product.user.nil?
        errors.add(:base, "Each item in the order must belong to a seller.")
      end
    end
  end

  after_create :notify_sellers_of_purchase

  private

  def order_date_must_be_today
    return unless order_date.present? && order_date.to_date != Date.current

    errors.add(:order_date, "must be today's date")
  end

  def notify_sellers_of_purchase
    order_items.each do |item|
      seller = item.product.user
      Notification.create!(
        recipient: seller,
        actor: user,
        action: 'purchased your item',
        notifiable: self
      )
    end
  end

  public

  def mark_as_delivered!
    update!(status: "Delivered")
    Notification.create!(
      recipient: user,
      actor: user,
      action: 'your order has been delivered',
      notifiable: self
    )
  end

  def item_name
    order_items.first&.product&.name || "Unnamed Item"
  end
end
