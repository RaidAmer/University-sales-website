class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.references :actor, polymorphic: true
      t.string :action
      t.references :notifiable, polymorphic: true
      t.boolean :read, default: false, null: false
      t.timestamps
    end
  end
end
