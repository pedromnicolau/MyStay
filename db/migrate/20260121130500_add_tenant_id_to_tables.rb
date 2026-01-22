class AddTenantIdToTables < ActiveRecord::Migration[8.0]
  def up
    add_reference :users, :tenant, null: true, foreign_key: true
    add_reference :people, :tenant, null: true, foreign_key: true
    add_reference :properties, :tenant, null: true, foreign_key: true
    add_reference :services, :tenant, null: true, foreign_key: true
    add_reference :service_types, :tenant, null: true, foreign_key: true

    # Backfill existing records to a default tenant
    default_tenant = Tenant.first || Tenant.create!(
      name: 'Default Tenant',
      document: "00000000000",
      password: SecureRandom.hex(8),
      password_confirmation: 'temporary',
      message: 'Bem-vindo ao MyStay'
    )
    # Ensure password_digest is set even if validations skipped
    if default_tenant.password_digest.blank?
      default_tenant.update!(password: 'temporary', password_confirmation: 'temporary')
    end

    execute "UPDATE users SET tenant_id = #{default_tenant.id} WHERE tenant_id IS NULL"
    execute "UPDATE people SET tenant_id = #{default_tenant.id} WHERE tenant_id IS NULL"
    execute "UPDATE properties SET tenant_id = #{default_tenant.id} WHERE tenant_id IS NULL"
    execute "UPDATE services SET tenant_id = #{default_tenant.id} WHERE tenant_id IS NULL"
    execute "UPDATE service_types SET tenant_id = #{default_tenant.id} WHERE tenant_id IS NULL"

    change_column_null :users, :tenant_id, false
    change_column_null :people, :tenant_id, false
    change_column_null :properties, :tenant_id, false
    change_column_null :services, :tenant_id, false
    change_column_null :service_types, :tenant_id, false

    add_index :users, [ :tenant_id, :email ]
    add_index :service_types, [ :tenant_id, :name ]
    add_index :services, [ :tenant_id, :booking_reference ]
    add_index :people, [ :tenant_id, :cpf ]
    add_index :people, [ :tenant_id, :rg ], unique: true, where: "rg IS NOT NULL AND rg != ''"
  end

  def down
    remove_index :people, [ :tenant_id, :rg ]
    remove_index :people, [ :tenant_id, :cpf ]
    remove_index :services, [ :tenant_id, :booking_reference ]
    remove_index :service_types, [ :tenant_id, :name ]
    remove_index :users, [ :tenant_id, :email ]

    remove_reference :service_types, :tenant, foreign_key: true
    remove_reference :services, :tenant, foreign_key: true
    remove_reference :properties, :tenant, foreign_key: true
    remove_reference :people, :tenant, foreign_key: true
    remove_reference :users, :tenant, foreign_key: true
  end
end
