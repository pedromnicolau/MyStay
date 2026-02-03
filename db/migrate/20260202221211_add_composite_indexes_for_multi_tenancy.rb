class AddCompositeIndexesForMultiTenancy < ActiveRecord::Migration[8.0]
  def change
    remove_index :movements, name: "index_movements_on_customer_id", if_exists: true
    remove_index :movements, name: "index_movements_on_property_id", if_exists: true
    remove_index :movements, name: "index_movements_on_seller_id", if_exists: true
    remove_index :movements, name: "index_movements_on_service_type_id", if_exists: true
    remove_index :movements, name: "index_movements_on_type", if_exists: true
    remove_index :movements, name: "index_movements_on_user_id", if_exists: true

    add_index :movements, [ :tenant_id, :customer_id ], name: "index_movements_on_tenant_id_and_customer_id"
    add_index :movements, [ :tenant_id, :property_id ], name: "index_movements_on_tenant_id_and_property_id"
    add_index :movements, [ :tenant_id, :seller_id ], name: "index_movements_on_tenant_id_and_seller_id"
    add_index :movements, [ :tenant_id, :service_type_id ], name: "index_movements_on_tenant_id_and_service_type_id"
    add_index :movements, [ :tenant_id, :type ], name: "index_movements_on_tenant_id_and_type"
    add_index :movements, [ :tenant_id, :user_id ], name: "index_movements_on_tenant_id_and_user_id"
    add_index :movements, [ :tenant_id, :check_in_date ], name: "index_movements_on_tenant_id_and_check_in_date"

    remove_index :people, name: "index_people_on_city", if_exists: true
    remove_index :people, name: "index_people_on_user_id", if_exists: true

    add_index :people, [ :tenant_id, :city ], name: "index_people_on_tenant_id_and_city"
    add_index :people, [ :tenant_id, :user_id ], name: "index_people_on_tenant_id_and_user_id"

    remove_index :properties, name: "index_properties_on_active", if_exists: true
    remove_index :properties, name: "index_properties_on_city", if_exists: true
    remove_index :properties, name: "index_properties_on_user_id", if_exists: true

    add_index :properties, [ :tenant_id, :active ], name: "index_properties_on_tenant_id_and_active"
    add_index :properties, [ :tenant_id, :city ], name: "index_properties_on_tenant_id_and_city"
    add_index :properties, [ :tenant_id, :user_id ], name: "index_properties_on_tenant_id_and_user_id"
    add_index :properties, [ :tenant_id, :name ], unique: true, name: "index_properties_on_tenant_id_and_name"
  end
end
