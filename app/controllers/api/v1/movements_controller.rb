module Api
  module V1
    class MovementsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      before_action :set_movement, only: [ :show, :update, :destroy ]
      before_action :set_movement_with_associations, only: [ :contract ]

      def index
        # Por padrão, excluir Expenses (calendário de hospedagens mostra apenas Stay e Service)
        # Expenses tem seu próprio endpoint
        movements = current_user.movements.where.not(type: "Expense").with_attached_attachments.order(created_at: :desc)

        # Filtrar por datas se fornecidas
        if params[:start_date].present? && params[:end_date].present?
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])

          movements = movements.where(
            "check_in_date <= ? AND check_out_date >= ?",
            end_date,
            start_date
          )
        end

        render json: movements.map { |movement| serialize_movement(movement) }, status: :ok
      end

      def show
        render json: serialize_movement(@movement), status: :ok
      end

      def create
        klass = respond_to?(:movement_class, true) ? movement_class : Movement
        movement = klass.new(movement_payload)
        movement.user = current_user
        if movement.save
          process_attachments(movement)
          render json: serialize_movement(movement), status: :created
        else
          render json: { errors: movement.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @movement.update(movement_payload)
          process_attachments(@movement)
          render json: serialize_movement(@movement), status: :ok
        else
          render json: { errors: @movement.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @movement.destroy
        render json: { message: "Movement deleted successfully" }, status: :ok
      end

      def contract
        generator = ContractGenerator.new(@movement)
        file = generator.generate

        data = File.binread(file.path)
        send_data data,
                  filename: "Contrato-#{@movement.customer&.name&.parameterize || 'movimento'}.docx",
                  type: generator.content_type,
                  disposition: "attachment"
      ensure
        file&.close!
        file&.unlink
      end

      private

      def movement_params
        params.require(:movement).permit(:check_in_date, :check_out_date,
                                        :number_of_guests, :price_per_night,
                                        :total_price, :currency, :description, :address,
                                        :customer_id, :property_id,
                                        :seller_id, :total_due, :deposit_amount, :final_amount, :balance_due,
                                        :guest_note, :total_payable, :total_paid, :balance_payable, :seller_note,
                                        :service_type_id,
                                        attachments: [], remove_attachment_ids: [], attachments_order: [])
      end

      def movement_payload
        permitted = movement_params
        permitted = permitted.except(:remove_attachment_ids, :attachments, :attachments_order)
        permitted
      end

      def process_attachments(movement)
        attach_files(movement)
        purge_removed_attachments(movement)
        save_attachments_order(movement)
      end

      def attach_files(movement)
        new_files = params.dig(:movement, :attachments)
        return if new_files.blank?

        # Filter out objects with previewUrl (already existing attachments)
        # Only attach new File/Blob objects
        files_to_attach = Array(new_files).select do |file|
          file.is_a?(ActionDispatch::Http::UploadedFile) || file.is_a?(Rack::Multipart::UploadedFile)
        end

        movement.attachments.attach(files_to_attach) if files_to_attach.any?
      end

      def purge_removed_attachments(movement)
        ids = params.dig(:movement, :remove_attachment_ids)
        return if ids.blank?

        Array(ids).each do |attachment_id|
          attachment = movement.attachments.find_by(id: attachment_id)
          attachment&.purge_later
        end
      end

      def save_attachments_order(movement)
        order = params.dig(:movement, :attachments_order)
        return if order.blank?

        valid_ids = movement.attachments.pluck(:id)
        filtered_order = Array(order).select { |id| valid_ids.include?(id.to_i) }
        movement.update_column(:attachments_order, filtered_order) if movement.respond_to?(:attachments_order=)
      end

      def serialize_movement(movement)
        serialized = movement.as_json(
          include: {
            customer: { only: [ :id, :name, :phone, :email ] },
            property: { only: [ :id, :name, :address, :city, :state ] },
            seller: { only: [ :id, :name, :phone, :email ] },
            service_type: { only: [ :id, :name, :description ] }
          }
        )
        # Garantir que o type está sempre presente no JSON
        serialized["type"] = movement.type
        # Converter times para formato HH:MM para o frontend
        serialized["check_in_time"] = movement.check_in_time&.strftime("%H:%M")
        serialized["check_out_time"] = movement.check_out_time&.strftime("%H:%M")
        serialized["attachments"] = attachments_payload(movement)
        serialized["attachments_order"] = movement.attachments_order || [] if movement.respond_to?(:attachments_order)
        serialized
      end

      def attachments_payload(movement)
        order = movement.respond_to?(:attachments_order) ? movement.attachments_order : []

        attachments_list = movement.attachments.map do |attachment|
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

      def set_movement
        @movement = current_user.movements.where(tenant_id: current_tenant.id).with_attached_attachments.find(params[:id])
      end

      def set_movement_with_associations
        @movement = current_user.movements.where(tenant_id: current_tenant.id).includes(:customer, :property).find(params[:id])
      end
    end
  end
end
