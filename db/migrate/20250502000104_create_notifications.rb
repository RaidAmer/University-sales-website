class ChangeReadNullAndDefaultOnNotifications < ActiveRecord::Migration[7.1]
  def change
    change_column_default :notifications, :read, false
    change_column_null :notifications, :read, false
  end
end
