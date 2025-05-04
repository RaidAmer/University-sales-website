class CreateRecipients < ActiveRecord::Migration[7.1]
  def change
    create_table :recipients do |t|
      t.references :user, null: false, foreign_key: true
      t.references :notification, null: false, foreign_key: true

      t.timestamps
    end
  end
end
