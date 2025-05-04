# frozen_string_literal: true

class AddProductToReviews < ActiveRecord::Migration[7.1]
  def change
    add_reference :customer_reviews, :product, foreign_key: true
  end
end
