module Api
  module V1
    class StaysController < MovementsController
      def index
        movements = current_user.movements.where(tenant_id: current_tenant.id, type: "Stay")
          .with_attached_attachments
          .order(check_in_date: :desc)

        movements = movements.where(property_id: params[:property_id]) if params[:property_id].present?

        if params[:start_date].present? && params[:end_date].present?
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          movements = movements.where("check_in_date >= ? AND check_out_date <= ?", start_date, end_date)
        elsif params[:start_date].present?
          start_date = Date.parse(params[:start_date])
          movements = movements.where("check_in_date >= ?", start_date)
        elsif params[:end_date].present?
          end_date = Date.parse(params[:end_date])
          movements = movements.where("check_out_date <= ?", end_date)
        end

        render json: movements.map { |movement| serialize_movement(movement) }, status: :ok
      end

      private

      def movement_class
        Stay
      end

      def movement_params
        params.require(:stay).permit(:check_in_date, :check_out_date, :check_in_time, :check_out_time,
                                      :number_of_guests, :price_per_night,
                                      :total_price, :currency, :description, :address,
                                      :customer_id, :property_id,
                                      :seller_id, :total_due, :deposit_amount, :final_amount, :balance_due,
                                      :guest_note, :total_payable, :total_paid, :balance_payable, :seller_note,
                                      attachments: [], remove_attachment_ids: [], attachments_order: [])
      end
    end
  end
end
