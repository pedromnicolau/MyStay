class AddBookingFieldsToStays < ActiveRecord::Migration[8.0]
  def change
    add_reference :stays, :customer, foreign_key: { to_table: :people }
    add_reference :stays, :property, foreign_key: true
    add_reference :stays, :seller, foreign_key: { to_table: :people }

    add_decimal_columns :stays, :total_due, :deposit_amount, :final_amount,
                             :balance_due, :total_payable, :total_paid, :balance_payable

    add_column :stays, :guest_note, :text
    add_column :stays, :seller_note, :text
  end

  private

  def add_decimal_columns(table, *columns)
    columns.each do |column|
      add_column table, column, :decimal, precision: 10, scale: 2
    end
  end
end
