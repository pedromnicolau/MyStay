class RenameStaysToServices < ActiveRecord::Migration[8.0]
  def change
    rename_table :stays, :services
    add_reference :services, :service_type, foreign_key: true
  end
end
