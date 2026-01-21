class RemoveDescriptionFromServiceTypes < ActiveRecord::Migration[8.0]
  def change
    remove_column :service_types, :description, :text
  end
end
