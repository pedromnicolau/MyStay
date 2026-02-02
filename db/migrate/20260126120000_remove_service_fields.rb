class RemoveServiceFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :services, :property_name, :string
    remove_column :services, :property_type, :string
    remove_column :services, :bedrooms, :integer
    remove_column :services, :bathrooms, :integer
    remove_column :services, :amenities, :text
    remove_column :services, :booking_reference, :string
    remove_column :services, :guest_name, :string
    remove_column :services, :guest_email, :string
  end
end
