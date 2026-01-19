class ChangeUniquenessIndexOnPeople < ActiveRecord::Migration[8.0]
  def change
    remove_index :people, name: "index_people_on_user_id_and_cpf"
    add_index :people, :cpf, unique: true
  end
end
