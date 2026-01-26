class AddTypeToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :type, :string, null: false, default: "Service"
    add_index :services, :type
  end
end
