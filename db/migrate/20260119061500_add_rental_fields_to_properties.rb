class AddRentalFieldsToProperties < ActiveRecord::Migration[7.1]
  def change
    add_column :properties, :bedrooms, :integer, null: false, default: 0
    add_column :properties, :bathrooms, :integer, null: false, default: 0
    add_column :properties, :max_guests, :integer, null: false, default: 0

    add_column :properties, :air_conditioning, :boolean, null: false, default: false
    add_column :properties, :wifi, :boolean, null: false, default: false
    add_column :properties, :tv, :boolean, null: false, default: false
    add_column :properties, :kitchen, :boolean, null: false, default: false
    add_column :properties, :parking_included, :boolean, null: false, default: false

    # Extras comuns em locações de curto período
    add_column :properties, :washing_machine, :boolean, null: false, default: false
    add_column :properties, :pool, :boolean, null: false, default: false
    add_column :properties, :barbecue_grill, :boolean, null: false, default: false
    add_column :properties, :balcony, :boolean, null: false, default: false
    add_column :properties, :pet_friendly, :boolean, null: false, default: false
    add_column :properties, :wheelchair_accessible, :boolean, null: false, default: false

    # Pinned attachment (main image)
    add_column :properties, :main_attachment_id, :bigint
    add_index :properties, :main_attachment_id
  end
end
