class RemoveUserFromServiceTypes < ActiveRecord::Migration[8.0]
  def change
    remove_index :service_types, [ :user_id, :name ]
    remove_reference :service_types, :user, foreign_key: true
    add_index :service_types, :name, unique: true
  end
end
