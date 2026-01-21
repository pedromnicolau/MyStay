module Api
  module V1
    class ServicesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      before_action :set_service, only: [ :show, :update, :destroy ]
      before_action :set_service_with_associations, only: [ :contract ]

      def index
        services = current_user.services.order(created_at: :desc)

        # Filtrar por datas se fornecidas
        if params[:start_date].present? && params[:end_date].present?
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])

          services = services.where(
            "check_in_date <= ? AND check_out_date >= ?",
            end_date,
            start_date
          )
        end

        render json: services, status: :ok
      end

      def show
        render json: @service, status: :ok
      end

      def create
        service = current_user.services.build(service_params)
        if service.save
          render json: service, status: :created
        else
          render json: { errors: service.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @service.update(service_params)
          render json: @service, status: :ok
        else
          render json: { errors: @service.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @service.destroy
        render json: { message: "Service deleted successfully" }, status: :ok
      end

      def contract
        generator = ContractGenerator.new(@service)
        file = generator.generate

        data = File.binread(file.path)
        send_data data,
                  filename: "Contrato-#{@service.guest_name.to_s.parameterize}.docx",
                  type: generator.content_type,
                  disposition: "attachment"
      ensure
        file&.close!
        file&.unlink
      end

      private

      def service_params
        params.require(:service).permit(:property_name, :property_type, :check_in_date, :check_out_date,
                                        :number_of_guests, :bedrooms, :bathrooms, :price_per_night,
                                        :total_price, :currency, :description, :address, :amenities,
                                        :guest_name, :guest_email, :customer_id, :property_id,
                                        :seller_id, :total_due, :deposit_amount, :final_amount, :balance_due,
                                        :guest_note, :total_payable, :total_paid, :balance_payable, :seller_note,
                                        :service_type_id)
      end

      def set_service
        @service = current_user.services.find(params[:id])
      end

      def set_service_with_associations
        @service = current_user.services.includes(:customer, :property).find(params[:id])
      end
    end
  end
end
