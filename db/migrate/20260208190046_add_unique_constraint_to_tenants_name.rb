class AddUniqueConstraintToTenantsName < ActiveRecord::Migration[8.0]
  def up
    # Remove the existing non-unique index
    remove_index :tenants, name: "index_tenants_on_name", if_exists: true

    # Add a new unique index on name
    add_index :tenants, :name, unique: true, name: "index_tenants_on_name"
  end

  def down
    # Remove the unique index
    remove_index :tenants, name: "index_tenants_on_name", if_exists: true

    # Recreate the non-unique index
    add_index :tenants, :name, name: "index_tenants_on_name"
  end
end
