class ChangeDefaultForNotificationsRead < ActiveRecord::Migration[7.1]
  def change
    change_column_default :notifications, :read, from: nil, to: false
  end
end
