class RefactorTenantAndUserSchema < ActiveRecord::Migration[8.0]
  def up
    # Remove document and address fields from tenants
    remove_index :tenants, name: "index_tenants_on_document"
    remove_column :tenants, :document
    remove_column :tenants, :city
    remove_column :tenants, :state
    remove_column :tenants, :address
    remove_column :tenants, :zip
    remove_column :tenants, :phone

    # Ensure master_code is still unique and required
    change_column_null :tenants, :master_code, false

    # Remove password from tenants (will be stored in users instead)
    remove_column :tenants, :password_digest
    remove_column :tenants, :email
    remove_column :tenants, :message

    # Remove address-related fields from users
    remove_column :users, :zip
    remove_column :users, :address
    remove_column :users, :number
    remove_column :users, :neighborhood
    remove_column :users, :state
    remove_column :users, :city
    remove_column :users, :cpf
  end

  def down
    # Restore address-related fields to users
    add_column :users, :cpf, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :neighborhood, :string
    add_column :users, :number, :string
    add_column :users, :address, :string
    add_column :users, :zip, :string
    add_column :tenants, :message, :text
    add_column :tenants, :email, :string
    add_column :tenants, :password_digest, :string, null: false
    add_column :tenants, :zip, :string
    add_column :tenants, :address, :string
    add_column :tenants, :state, :string
    add_column :tenants, :city, :string
    add_column :tenants, :phone, :string
    add_column :tenants, :document, :string, null: false
    add_index :tenants, :document, unique: true
    change_column_null :tenants, :master_code, true
    remove_index :tenants, name: "index_tenants_on_master_code"
  end
end
