# frozen_string_literal: true

class AddUserToReviews < ActiveRecord::Migration[7.1]
  def change
    add_reference :customer_reviews, :user, foreign_key: true
  end
end
