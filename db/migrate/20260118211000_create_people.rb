class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :cpf, null: false
      t.string :rg
      t.string :phone, null: false
      t.string :email
      t.string :profession
      t.string :marital_status
      t.string :city
      t.string :address
      t.string :neighborhood
      t.string :zip
      t.string :note
      t.boolean :blocked, default: false
      t.text :comments
      t.string :type, null: false
      t.timestamps
    end

    add_index :people, [ :user_id, :cpf ], unique: true
    add_index :people, :city
    add_index :people, :type
  end
end
