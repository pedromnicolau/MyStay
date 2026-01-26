class Api::V1::PublicPropertiesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def showcase
    # List all active properties from all tenants with images
    properties = Property.where(active: true)
      .with_attached_attachments
      .order(created_at: :desc)
      .limit(params[:limit] || 50)

    render json: properties.map { |property| serialize_property_for_showcase(property) }, status: :ok
  end

  def show
    property = Property.with_attached_attachments.find_by(id: params[:id], active: true)

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
      updated_at: property.updated_at
    }
  end
end
