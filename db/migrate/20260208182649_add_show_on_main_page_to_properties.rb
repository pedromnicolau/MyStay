class AddShowOnMainPageToProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :properties, :show_on_main_page, :boolean, default: false, null: false
  end
end
