# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  description :string
#  is_featured :boolean
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Category < ApplicationRecord
  has_many(
    :products,
    class_name:  'Product',
    foreign_key: 'category_id',
    inverse_of:  :category,
    dependent:   :destroy
  )

  has_one_attached :icon

  validates :name, presence: true, uniqueness: true
end
