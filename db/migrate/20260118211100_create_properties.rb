class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :address
      t.string :neighborhood
      t.string :zip
      t.string :city
      t.string :state
      t.string :image
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :properties, :city
    add_index :properties, :active
  end
end
