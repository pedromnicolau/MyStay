class Api::V1::PropertiesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_property, only: [ :show, :update, :destroy ]

  def index
    properties = Property.where(tenant_id: current_tenant.id).includes(:user).with_attached_attachments.order(created_at: :desc)
    render json: properties.map { |property| serialize_property(property) }, status: :ok
  end

  def show
    render json: serialize_property(@property), status: :ok
  end

  def create
    payload = property_payload
    # Use user_id from payload if present, otherwise use current_user
    payload[:user_id] = current_user.id if payload[:user_id].blank?
    # Ensure tenant_id is set from current_tenant
    payload[:tenant_id] = current_tenant.id

    property = Property.new(payload)

    if property.save
      process_attachments(property)
      render json: serialize_property(property), status: :created
    else
      render json: { errors: property.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @property.update(property_payload)
      process_attachments(@property)
      render json: serialize_property(@property), status: :ok
    else
      render json: { errors: @property.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy
    render json: { message: "Imóvel removido" }, status: :ok
  rescue ActiveRecord::InvalidForeignKey => e
    render_deletion_conflict_error
  end

  private

  def set_property
    @property = Property.where(tenant_id: current_tenant.id).includes(:user).with_attached_attachments.find(params[:id])
  end

  def property_params
    params.require(:property).permit(
      :name, :description, :address, :number, :neighborhood, :zip, :city, :state, :active, :show_on_main_page,
      :user_id,
      :bedrooms, :bathrooms, :max_guests,
      :air_conditioning, :wifi, :tv, :kitchen, :parking_included,
      :washing_machine, :pool, :barbecue_grill, :balcony, :pet_friendly, :wheelchair_accessible,
      :main_attachment_id, :main_attachment_name, :contract,
      attachments: [], remove_attachment_ids: [], attachments_order: []
    )
  end

  def property_payload
    permitted = property_params
    permitted = permitted.except(:remove_attachment_ids, :attachments, :contract)
    permitted = permitted.except(:main_attachment_id, :main_attachment_name) unless Property.new.respond_to?(:main_attachment_id)
    permitted
  end

  def process_attachments(property)
    attach_files(property)
    attach_contract(property)
    purge_removed_attachments(property)
    assign_main_attachment_if_needed(property)
    save_attachments_order(property)
  end

  def attach_files(property)
    new_files = params.dig(:property, :attachments)
    return if new_files.blank?
    property.attachments.attach(new_files)
  end

  def attach_contract(property)
    contract_file = params.dig(:property, :contract)
    return if contract_file.blank?
    # Only attach if it's a new file upload, not an existing contract object
    return unless contract_file.is_a?(ActionDispatch::Http::UploadedFile)
    property.contract.attach(contract_file)
  end

  def purge_removed_attachments(property)
    ids = params.dig(:property, :remove_attachment_ids)
    return if ids.blank?

    Array(ids).each do |attachment_id|
      attachment = property.attachments.find_by(id: attachment_id)
      attachment&.purge_later
    end

    if property.respond_to?(:main_attachment_id) && property.main_attachment_id.present? && Array(ids).map(&:to_s).include?(property.main_attachment_id.to_s)
      property.update_column(:main_attachment_id, nil)
    end
  end

  def serialize_property(property)
    serialized = property.as_json
    serialized["attachments"] = attachments_payload(property)
    serialized["attachments_order"] = property.attachments_order || [] if property.respond_to?(:attachments_order)
    serialized["contract"] = contract_payload(property) if property.contract.attached?

    # Include user information
    if property.user
      serialized["user"] = {
        id: property.user.id,
        first_name: property.user.first_name,
        last_name: property.user.last_name,
        email: property.user.email
      }
    end

    serialized
  end

  def contract_payload(property)
    attachment = property.contract.attachment
    return nil unless attachment

    {
      id: attachment.id,
      filename: attachment.filename.to_s,
      content_type: attachment.content_type,
      byte_size: attachment.byte_size,
      created_at: attachment.created_at,
      url: url_for(attachment)
    }
  end

  def attachments_payload(property)
    main_id = property.respond_to?(:main_attachment_id) ? property.main_attachment_id : nil
    order = property.respond_to?(:attachments_order) ? property.attachments_order : []

    attachments_list = property.attachments.map do |attachment|
      {
        id: attachment.id,
        filename: attachment.filename.to_s,
        content_type: attachment.content_type,
        byte_size: attachment.byte_size,
        created_at: attachment.created_at,
        url: url_for(attachment),
        is_main: main_id.present? && attachment.id == main_id
      }
    end

    if order.any?
      position_map = order.each_with_index.to_h
      pinned = attachments_list.select { |att| att[:is_main] }
      unpinned = attachments_list.reject { |att| att[:is_main] }
      unpinned.sort_by! { |att| position_map[att[:id]] || Float::INFINITY }
      pinned + unpinned
    else
      attachments_list.sort_by { |att| att[:is_main] ? 0 : 1 }
    end
  end

  def assign_main_attachment_if_needed(property_record = @property)
    return unless property_record
    return unless property_record.respond_to?(:main_attachment_id)

    main_id = params.dig(:property, :main_attachment_id)
    if main_id.present?
      property_record.update_column(:main_attachment_id, main_id)
      return
    end

    main_name = params.dig(:property, :main_attachment_name)
    return if main_name.blank?

    candidate = property_record.attachments.where("active_storage_blobs.filename = ?", main_name)
      .joins(:blob)
      .order(created_at: :desc)
      .first

    property_record.update_column(:main_attachment_id, candidate.id) if candidate
  end

  def save_attachments_order(property_record = @property)
    return unless property_record
    return unless property_record.respond_to?(:attachments_order)

    order = params.dig(:property, :attachments_order)
    return if order.blank?

    valid_ids = property_record.attachments.pluck(:id)
    filtered_order = Array(order).select { |id| valid_ids.include?(id.to_i) }
    property_record.update_column(:attachments_order, filtered_order)
  end

  def render_deletion_conflict_error
    related_services = fetch_related_services
    error_message = build_deletion_error_message(related_services.length)

    render json: {
      error: error_message,
      message: "Por favor, primeiro remova ou atualize os serviços relacionados antes de excluir este imóvel.",
      related_stays: format_services_for_response(related_services),
      stays_count: related_services.length
    }, status: :conflict
  end

  def fetch_related_services
    Movement.where(property_id: @property.id, tenant_id: current_tenant.id)
        .select(:id, :check_in_date, :check_out_date)
        .order(check_in_date: :desc)
  end

  def build_deletion_error_message(services_count)
    "Não é possível excluir este imóvel pois existem #{services_count} serviço(s) vinculado(s) a ele."
  end

  def format_services_for_response(services)
    services.map do |service|
      {
        id: service.id,
        check_in_date: service.check_in_date,
        check_out_date: service.check_out_date
      }
    end
  end
end
