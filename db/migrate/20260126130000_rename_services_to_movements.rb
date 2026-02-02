class RenameServicesToMovements < ActiveRecord::Migration[7.0]
  def change
    rename_table :services, :movements
  end
end
