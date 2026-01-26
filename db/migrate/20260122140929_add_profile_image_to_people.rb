class AddProfileImageToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :profile_image, :string
  end
end
