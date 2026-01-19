class RemoveCountryFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :country, :string
  end
end
