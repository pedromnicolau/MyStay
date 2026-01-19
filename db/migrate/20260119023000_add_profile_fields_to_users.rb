class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :zip, :string
    add_column :users, :address, :string
    add_column :users, :number, :string
    add_column :users, :neighborhood, :string
    add_column :users, :state, :string
  end
end
