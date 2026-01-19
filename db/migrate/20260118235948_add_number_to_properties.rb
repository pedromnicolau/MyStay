class AddNumberToProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :properties, :number, :string
  end
end
