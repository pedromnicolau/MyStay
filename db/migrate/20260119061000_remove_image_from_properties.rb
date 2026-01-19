class RemoveImageFromProperties < ActiveRecord::Migration[8.0]
  def change
    remove_column :properties, :image, :string
  end
end
