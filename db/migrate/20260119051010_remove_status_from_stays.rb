class RemoveStatusFromStays < ActiveRecord::Migration[8.0]
  def change
    remove_index :stays, :status if index_exists?(:stays, :status)
    remove_column :stays, :status, :string
  end
end
