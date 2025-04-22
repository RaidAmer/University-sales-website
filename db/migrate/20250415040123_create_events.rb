# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :event_name
      t.string :location
      t.datetime :date
      t.float :price
      t.integer :capacity
      t.text :registered_users
      t.text :description
      t.string :image

      t.timestamps
    end

    add_index :events, :event_name, unique: true
  end
end
