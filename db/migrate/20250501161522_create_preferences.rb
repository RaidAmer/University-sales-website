class CreatePreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :theme
      t.boolean :show_welcome

      t.timestamps
    end
  end
end
