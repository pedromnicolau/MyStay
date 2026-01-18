class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :country
      t.string :city
      t.string :profile_image

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
