class CreateCustomerReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_reviews do |t|
      t.string :title
      t.text :description
      t.integer :rating

      t.timestamps
    end
  end
end
