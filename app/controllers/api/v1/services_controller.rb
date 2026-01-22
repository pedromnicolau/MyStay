module Api
  module V1
    class ServicesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      before_action :set_service, only: [ :show, :update, :destroy ]
      before_action :set_service_with_associations, only: [ :contract ]

      def index
        services = current_user.services.with_attached_attachments.order(created_at: :desc)

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

        render json: services.map { |service| serialize_service(service) }, status: :ok
      end

      def show
        render json: serialize_service(@service), status: :ok
      end

      def create
        service = current_user.services.build(service_payload)
        if service.save
          process_attachments(service)
          render json: serialize_service(service), status: :created
        else
          render json: { errors: service.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @service.update(service_payload)
          process_attachments(@service)
          render json: serialize_service(@service), status: :ok
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
                                        :service_type_id,
                                        attachments: [], remove_attachment_ids: [], attachments_order: [])
      end

      def service_payload
        permitted = service_params
        permitted = permitted.except(:remove_attachment_ids, :attachments, :attachments_order)
        permitted
      end

      def process_attachments(service)
        attach_files(service)
        purge_removed_attachments(service)
        save_attachments_order(service)
      end

      def attach_files(service)
        new_files = params.dig(:service, :attachments)
        return if new_files.blank?

        # Filter out objects with previewUrl (already existing attachments)
        # Only attach new File/Blob objects
        files_to_attach = Array(new_files).select do |file|
          file.is_a?(ActionDispatch::Http::UploadedFile) || file.is_a?(Rack::Multipart::UploadedFile)
        end

        service.attachments.attach(files_to_attach) if files_to_attach.any?
      end

      def purge_removed_attachments(service)
        ids = params.dig(:service, :remove_attachment_ids)
        return if ids.blank?

        Array(ids).each do |attachment_id|
          attachment = service.attachments.find_by(id: attachment_id)
          attachment&.purge_later
        end
      end

      def save_attachments_order(service)
        order = params.dig(:service, :attachments_order)
        return if order.blank?

        valid_ids = service.attachments.pluck(:id)
        filtered_order = Array(order).select { |id| valid_ids.include?(id.to_i) }
        service.update_column(:attachments_order, filtered_order) if service.respond_to?(:attachments_order=)
      end

      def serialize_service(service)
        serialized = service.as_json
        serialized["attachments"] = attachments_payload(service)
        serialized["attachments_order"] = service.attachments_order || [] if service.respond_to?(:attachments_order)
        serialized
      end

      def attachments_payload(service)
        order = service.respond_to?(:attachments_order) ? service.attachments_order : []

        attachments_list = service.attachments.map do |attachment|
          {
            id: attachment.id,
            filename: attachment.filename.to_s,
            content_type: attachment.content_type,
            byte_size: attachment.byte_size,
            created_at: attachment.created_at,
            url: url_for(attachment)
          }
        end

        if order.any?
          position_map = order.each_with_index.to_h
          attachments_list.sort_by { |att| position_map[att[:id]] || Float::INFINITY }
        else
          attachments_list
        end
      end

      def set_service
        @service = current_user.services.with_attached_attachments.find(params[:id])
      end

      def set_service_with_associations
        @service = current_user.services.includes(:customer, :property).find(params[:id])
      end
    end
  end
end
