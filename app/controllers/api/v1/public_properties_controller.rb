class Api::V1::PublicPropertiesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def showcase
    # Base query for active properties
    properties = Property.where(active: true)
      .with_attached_attachments
      .order(created_at: :desc)

    tenant_info = nil
    if params[:tenant_code].present?
      # If tenant_code is provided, show all active properties from that tenant
      tenant = Tenant.find_by(master_code: params[:tenant_code])
      if tenant
        properties = properties.where(tenant_id: tenant.id)
        tenant_info = { id: tenant.id, name: tenant.name, master_code: tenant.master_code }
      else
        properties = properties.none
      end
    else
      # If no tenant_code, only show properties with show_on_main_page = true
      properties = properties.where(show_on_main_page: true)
    end

    properties = properties.limit(params[:limit] || 50)

    result = {
      properties: properties.map { |property| serialize_property_for_showcase(property) }
    }
    result[:tenant] = tenant_info if tenant_info

    render json: result, status: :ok
  end

  def show
    property = Property.with_attached_attachments.includes(:user).find_by(id: params[:id], active: true)

    if property
      render json: serialize_property_for_detail(property), status: :ok
    else
      render json: { error: "Imóvel não encontrado" }, status: :not_found
    end
  end

  private

  def serialize_property_for_showcase(property)
    images = property.attachments.map { |attachment| url_for(attachment) }

    {
      id: property.id,
      name: property.name,
      city: property.city,
      neighborhood: property.neighborhood,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      max_guests: property.max_guests,
      images: images,
      main_image: images.first,
      tenant_id: property.tenant_id,
      description_short: property.description&.truncate(100),
      show_on_main_page: property.show_on_main_page,
      amenities: {
        air_conditioning: property.air_conditioning,
        wifi: property.wifi,
        tv: property.tv,
        kitchen: property.kitchen,
        parking_included: property.parking_included,
        washing_machine: property.washing_machine,
        pool: property.pool,
        barbecue_grill: property.barbecue_grill,
        balcony: property.balcony,
        pet_friendly: property.pet_friendly,
        wheelchair_accessible: property.wheelchair_accessible
      }
    }
  end

  def serialize_property_for_detail(property)
    images = property.attachments.map { |attachment| url_for(attachment) }

    # Get unavailable dates from stays/movements (next 365 days)
    unavailable_dates = Movement.where(property_id: property.id)
      .where("check_out_date >= ?", Date.today)
      .pluck(:check_in_date, :check_out_date)
      .flat_map { |check_in, check_out| (check_in...check_out).to_a }
      .map { |date| date.strftime("%Y-%m-%d") }

    {
      id: property.id,
      name: property.name,
      description: property.description,
      address: property.address,
      number: property.number,
      neighborhood: property.neighborhood,
      zip: property.zip,
      city: property.city,
      state: property.state,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      max_guests: property.max_guests,
      show_on_main_page: property.show_on_main_page,
      amenities: {
        air_conditioning: property.air_conditioning,
        wifi: property.wifi,
        tv: property.tv,
        kitchen: property.kitchen,
        parking_included: property.parking_included,
        washing_machine: property.washing_machine,
        pool: property.pool,
        barbecue_grill: property.barbecue_grill,
        balcony: property.balcony,
        pet_friendly: property.pet_friendly,
        wheelchair_accessible: property.wheelchair_accessible
      },
      images: images,
      tenant_id: property.tenant_id,
      created_at: property.created_at,
      updated_at: property.updated_at,
      user: property.user ? {
        id: property.user.id,
        first_name: property.user.first_name,
        last_name: property.user.last_name,
        email: property.user.email,
        phone: property.user.phone,
        profile_image: property.user.profile_image.attached? ? url_for(property.user.profile_image) : nil
      } : nil,
      unavailable_dates: unavailable_dates
    }
  end
end
