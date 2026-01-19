class Api::V1::StaysController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_stay, only: [ :show, :update, :destroy ]
  before_action :set_stay_with_associations, only: [ :contract ]

  def index
    stays = current_user.stays.order(created_at: :desc)
    render json: stays, status: :ok
  end

  def show
    render json: @stay, status: :ok
  end

  def create
    stay = current_user.stays.build(stay_params)
    if stay.save
      render json: stay, status: :created
    else
      render json: { errors: stay.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @stay.update(stay_params)
      render json: @stay, status: :ok
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
                                  :guest_note, :total_payable, :total_paid, :balance_payable, :seller_note)
  end

  def set_stay
    @stay = current_user.stays.find(params[:id])
  end

  def set_stay_with_associations
    @stay = current_user.stays.includes(:customer, :property).find(params[:id])
  end
end
