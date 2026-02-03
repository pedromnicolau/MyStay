module Api
  module V1
    class ServicesController < MovementsController
      private

      def movement_class
        Service
      end

      def movement_params
        params.require(:service).permit(:check_in_date, :check_out_date, :check_in_time, :check_out_time,
                                        :number_of_guests, :price_per_night,
                                        :total_price, :currency, :description, :address,
                                        :customer_id, :property_id,
                                        :seller_id, :total_due, :deposit_amount, :final_amount, :balance_due,
                                        :guest_note, :total_payable, :total_paid, :balance_payable, :seller_note,
                                        :service_type_id,
                                        attachments: [], remove_attachment_ids: [], attachments_order: [])
      end
    end
  end
end
