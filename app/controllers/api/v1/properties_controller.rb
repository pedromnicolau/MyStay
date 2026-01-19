class Api::V1::PropertiesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_property, only: [ :show, :update, :destroy ]

  def index
    properties = current_user.properties.order(created_at: :desc)
    render json: properties, status: :ok
  end

  def show
    render json: @property, status: :ok
  end

  def create
    property = current_user.properties.build(property_params)
    if property.save
      render json: property, status: :created
    else
      render json: { errors: property.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @property.update(property_params)
      render json: @property, status: :ok
    else
      render json: { errors: @property.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy
    render json: { message: "Imóvel removido" }, status: :ok
  end

  private

  def set_property
    @property = current_user.properties.find(params[:id])
  end

  def property_params
    params.require(:property).permit(:name, :address, :number, :neighborhood, :zip, :city, :state, :image, :active)
  end
end
