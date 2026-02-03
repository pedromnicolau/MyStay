class UpdateIndexesAndEnforceNotNullTenantId < ActiveRecord::Migration[8.0]
  def change
    remove_index :service_types, name: "index_service_types_on_tenant_id_and_name", if_exists: true

    add_index :tenants, :name, name: "index_tenants_on_name"

    remove_index :users, name: "index_users_on_tenant_id_and_email", if_exists: true
    remove_index :users, name: "index_users_on_cpf", if_exists: true
    add_index :users, [ :tenant_id, :cpf ], name: "index_users_on_tenant_id_and_cpf"

    change_column_null :movements, :tenant_id, false
    change_column_null :people, :tenant_id, false
    change_column_null :properties, :tenant_id, false
    change_column_null :service_types, :tenant_id, false
    change_column_null :users, :tenant_id, false
  end
end
