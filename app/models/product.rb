# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  description :text
#  image       :string
#  name        :string
#  price       :float
#  status      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint
#
# Indexes
#
#  index_products_on_category_id  (category_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
class Product < ApplicationRecord
  enum status: { Active: 0, Inactive: 1, Sold: 2 }

  has_one_attached :image

  validates :image, presence: true
  validates :name, presence: true
  validates :price, presence:true, numericality: { greater_than_or_equal_to: 0 }
end
