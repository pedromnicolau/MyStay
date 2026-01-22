class Api::V1::StaysController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_stay, only: [ :show, :update, :destroy ]
  before_action :set_stay_with_associations, only: [ :contract ]

  def index
    stays = current_user.stays.with_attached_attachments.order(created_at: :desc)
    render json: stays.map { |stay| serialize_stay(stay) }, status: :ok
  end

  def show
    render json: serialize_stay(@stay), status: :ok
  end

  def create
    stay = current_user.stays.build(stay_payload)
    if stay.save
      process_attachments(stay)
      render json: serialize_stay(stay), status: :created
    else
      render json: { errors: stay.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @stay.update(stay_payload)
      process_attachments(@stay)
      render json: serialize_stay(@stay), status: :ok
    else
      render json: { errors: @stay.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @stay.destroy
    render json: { message: "Stay deleted successfully" }, status: :ok
  end

  def contract
    generator = ContractGenerator.new(@stay)
    file = generator.generate

    data = File.binread(file.path)
    send_data data,
              filename: "Contrato-#{@stay.guest_name.to_s.parameterize}.docx",
              type: generator.content_type,
              disposition: "attachment"
  ensure
    file&.close!
    file&.unlink
  end

  private

  def stay_params
    params.require(:stay).permit(:property_name, :property_type, :check_in_date, :check_out_date,
                                  :number_of_guests, :bedrooms, :bathrooms, :price_per_night,
                                  :total_price, :currency, :description, :address, :amenities,
                                  :guest_name, :guest_email, :customer_id, :property_id,
                                  :seller_id, :total_due, :deposit_amount, :final_amount, :balance_due,
                                  :guest_note, :total_payable, :total_paid, :balance_payable, :seller_note,
                                  attachments: [], remove_attachment_ids: [], attachments_order: [])
  end

  def stay_payload
    permitted = stay_params
    permitted = permitted.except(:remove_attachment_ids, :attachments, :attachments_order)
    permitted
  end

  def process_attachments(stay)
    attach_files(stay)
    purge_removed_attachments(stay)
    save_attachments_order(stay)
  end

  def attach_files(stay)
    new_files = params.dig(:stay, :attachments)
    return if new_files.blank?

    # Filter out objects with previewUrl (already existing attachments)
    # Only attach new File/Blob objects
    files_to_attach = Array(new_files).select do |file|
      file.is_a?(ActionDispatch::Http::UploadedFile) || file.is_a?(Rack::Multipart::UploadedFile)
    end

    stay.attachments.attach(files_to_attach) if files_to_attach.any?
  end

  def purge_removed_attachments(stay)
    ids = params.dig(:stay, :remove_attachment_ids)
    return if ids.blank?

    Array(ids).each do |attachment_id|
      attachment = stay.attachments.find_by(id: attachment_id)
      attachment&.purge_later
    end
  end

  def save_attachments_order(stay)
    order = params.dig(:stay, :attachments_order)
    return if order.blank?

    valid_ids = stay.attachments.pluck(:id)
    filtered_order = Array(order).select { |id| valid_ids.include?(id.to_i) }
    stay.update_column(:attachments_order, filtered_order) if stay.respond_to?(:attachments_order=)
  end

  def serialize_stay(stay)
    serialized = stay.as_json
    serialized["attachments"] = attachments_payload(stay)
    serialized["attachments_order"] = stay.attachments_order || [] if stay.respond_to?(:attachments_order)
    serialized
  end

  def attachments_payload(stay)
    order = stay.respond_to?(:attachments_order) ? stay.attachments_order : []

    attachments_list = stay.attachments.map do |attachment|
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

  def set_stay
    @stay = current_user.stays.with_attached_attachments.find(params[:id])
  end

  def set_stay_with_associations
    @stay = current_user.stays.includes(:customer, :property).find(params[:id])
  end
end
