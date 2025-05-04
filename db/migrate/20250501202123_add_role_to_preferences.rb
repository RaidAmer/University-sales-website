class AddRoleToPreferences < ActiveRecord::Migration[7.1]
  def change
    add_column :preferences, :role, :string
  end
end
