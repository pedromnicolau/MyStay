class AddAttachmentsOrderToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :attachments_order, :json, default: []
  end
end
