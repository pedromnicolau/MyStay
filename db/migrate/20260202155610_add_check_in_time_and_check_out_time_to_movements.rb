class AddCheckInTimeAndCheckOutTimeToMovements < ActiveRecord::Migration[8.0]
  def change
    add_column :movements, :check_in_time, :time
    add_column :movements, :check_out_time, :time
  end
end
