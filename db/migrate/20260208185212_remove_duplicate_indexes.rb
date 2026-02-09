class RemoveDuplicateIndexes < ActiveRecord::Migration[8.0]
  def up
    # Remove duplicate index on people table (tenant_id, document)
    # Keeping index_people_on_tenant_and_cpf (unique index)
    remove_index :people, name: "index_people_on_tenant_id_and_document", if_exists: true

    # Remove duplicate index on people table (tenant_id, rg)
    # Keeping index_people_on_tenant_and_rg (unique index with where clause)
    remove_index :people, name: "index_people_on_tenant_id_and_rg", if_exists: true

    # Remove duplicate index on service_types table (tenant_id)
    # Keeping index_service_types_on_tenant_and_name (unique compound index)
    remove_index :service_types, name: "index_service_types_on_tenant_id", if_exists: true
  end

  def down
    # Re-create indexes if needed (for rollback)
    add_index :people, [ :tenant_id, :document ], name: "index_people_on_tenant_id_and_document"
    add_index :people, [ :tenant_id, :rg ], name: "index_people_on_tenant_id_and_rg", unique: true, where: "rg IS NOT NULL AND rg != ''"
    add_index :service_types, :tenant_id, name: "index_service_types_on_tenant_id"
  end
end
