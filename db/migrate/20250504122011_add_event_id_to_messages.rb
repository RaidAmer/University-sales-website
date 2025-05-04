class AddEventIdToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :event_id, :bigint
  end
end
