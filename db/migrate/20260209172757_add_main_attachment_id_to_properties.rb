class AddMainAttachmentIdToProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :properties, :main_attachment_id, :bigint
  end
end
