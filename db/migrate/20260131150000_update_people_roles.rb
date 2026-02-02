class UpdatePeopleRoles < ActiveRecord::Migration[8.0]
  def up
    add_column :people, :customer, :boolean, default: false, null: false
    add_column :people, :provider, :boolean, default: false, null: false
    add_column :people, :agent, :boolean, default: false, null: false

    execute <<~SQL
      UPDATE people SET customer = TRUE WHERE type = 'Customer'
    SQL
    execute <<~SQL
      UPDATE people SET agent = TRUE WHERE type = 'Seller'
    SQL
    execute <<~SQL
      UPDATE people SET provider = TRUE WHERE type IN ('Cleaner', 'Provider')
    SQL

    remove_column :people, :type, :string
  end

  def down
    add_column :people, :type, :string

    execute <<~SQL
      UPDATE people SET type = CASE
        WHEN customer = TRUE THEN 'Customer'
        WHEN agent = TRUE THEN 'Seller'
        WHEN provider = TRUE THEN 'Provider'
        ELSE 'Customer'
      END
    SQL

    remove_column :people, :customer, :boolean
    remove_column :people, :provider, :boolean
    remove_column :people, :agent, :boolean
  end
end
