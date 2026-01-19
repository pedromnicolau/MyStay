class AddUniqueIndexToRg < ActiveRecord::Migration[8.0]
  def change
    add_index :people, :rg, unique: true, where: "rg IS NOT NULL AND rg != ''"
  end
end
