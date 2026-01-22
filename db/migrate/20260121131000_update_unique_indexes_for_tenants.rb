class UpdateUniqueIndexesForTenants < ActiveRecord::Migration[8.0]
  def change
    # Users email uniqueness per tenant
    remove_index :users, name: "index_users_on_email"
    add_index :users, [ :tenant_id, :email ], unique: true, name: "index_users_on_tenant_and_email"

    # People cpf and rg uniqueness per tenant
    remove_index :people, name: "index_people_on_cpf"
    remove_index :people, name: "index_people_on_rg"
    add_index :people, [ :tenant_id, :cpf ], unique: true, name: "index_people_on_tenant_and_cpf"
    add_index :people, [ :tenant_id, :rg ], unique: true, name: "index_people_on_tenant_and_rg", where: "rg IS NOT NULL AND rg != ''"

    # ServiceTypes name uniqueness per tenant
    remove_index :service_types, name: "index_service_types_on_name"
    add_index :service_types, [ :tenant_id, :name ], unique: true, name: "index_service_types_on_tenant_and_name"

    # Services booking_reference uniqueness per tenant
    remove_index :services, name: "index_services_on_booking_reference"
    add_index :services, [ :tenant_id, :booking_reference ], unique: true, name: "index_services_on_tenant_and_booking_reference"
  end
end
