class AddNumberAndStateToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :number, :string
    add_column :people, :state, :string
  end
end
