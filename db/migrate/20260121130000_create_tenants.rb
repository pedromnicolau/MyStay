class CreateTenants < ActiveRecord::Migration[8.0]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :document, null: false
      t.string :master_code, null: false
      t.text :message
      t.string :password_digest, null: false
      t.string :email
      t.string :phone
      t.string :city
      t.string :state
      t.string :address
      t.string :zip

      t.timestamps
    end

    add_index :tenants, :document, unique: true
    add_index :tenants, :master_code, unique: true
  end
end
