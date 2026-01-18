class CreateStays < ActiveRecord::Migration[8.0]
  def change
    create_table :stays do |t|
      t.references :user, null: false, foreign_key: true
      t.string :property_name, null: false
      t.string :property_type
      t.date :check_in_date, null: false
      t.date :check_out_date, null: false
      t.integer :number_of_guests
      t.integer :bedrooms
      t.integer :bathrooms
      t.decimal :price_per_night, precision: 10, scale: 2
      t.decimal :total_price, precision: 10, scale: 2
      t.string :currency, default: 'USD'
      t.text :description
      t.string :address
      t.text :amenities
      t.string :status, default: 'pending'
      t.string :booking_reference
      t.string :guest_name, null: false
      t.string :guest_email, null: false

      t.timestamps
    end

    add_index :stays, :status
    add_index :stays, :booking_reference, unique: true
  end
end
