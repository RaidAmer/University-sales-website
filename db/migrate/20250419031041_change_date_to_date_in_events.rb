# frozen_string_literal: true

class ChangeDateToDateInEvents < ActiveRecord::Migration[7.1]
  def change
    change_column :events, :date, :date
  end
end
