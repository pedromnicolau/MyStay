class AddAttachmentsOrderToProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :properties, :attachments_order, :json, default: []
  end
end
