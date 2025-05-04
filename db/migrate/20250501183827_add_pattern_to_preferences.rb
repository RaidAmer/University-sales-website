class AddPatternToPreferences < ActiveRecord::Migration[7.1]
  def change
    add_column :preferences, :pattern, :string
  end
end
