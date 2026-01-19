class Api::V1::PeopleController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_person, only: [ :show, :update, :destroy ]

  def index
    people = current_user.people.order(created_at: :desc)
    people = people.where(type: params[:type]) if params[:type].present?
    render json: people, status: :ok
  end

  def show
    render json: @person, status: :ok
  end

  def create
    person = current_user.people.build(person_params)
    if person.save
      render json: person, status: :created
    else
      render json: { errors: person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @person.update(person_params)
      render json: @person, status: :ok
    else
      render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @person.destroy
    render json: { message: "Registro removido" }, status: :ok
  rescue ActiveRecord::InvalidForeignKey => e
    # Verifica se é customer ou seller
    related_stays = if @person.type == "Customer"
      Stay.where(customer_id: @person.id).select(:id, :booking_reference, :guest_name, :check_in_date, :check_out_date)
    elsif @person.type == "Seller"
      Stay.where(seller_id: @person.id).select(:id, :booking_reference, :guest_name, :check_in_date, :check_out_date)
    else
      []
    end

    stay_details = related_stays.map do |stay|
      {
        id: stay.id,
        booking_reference: stay.booking_reference,
        guest_name: stay.guest_name,
        check_in_date: stay.check_in_date,
        check_out_date: stay.check_out_date
      }
    end

    stays_count = stay_details.length

    error_message = if @person.type == "Customer"
      "Não é possível excluir este cliente pois existem #{stays_count} estadia(s) vinculada(s) a ele."
    elsif @person.type == "Seller"
      "Não é possível excluir este vendedor pois existem #{stays_count} estadia(s) vinculada(s) a ele."
    else
      "Não é possível excluir este registro pois existem referências a ele no sistema."
    end

    render json: {
      error: error_message,
      message: "Por favor, primeiro remova ou atualize as estadias relacionadas antes de excluir este registro.",
      related_stays: stay_details,
      stays_count: stays_count
    }, status: :conflict
  end

  private

  def set_person
    @person = current_user.people.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:name, :cpf, :rg, :phone, :email, :profession, :marital_status,
                                   :city, :state, :address, :number, :neighborhood, :zip, :note, :blocked, :comments, :type)
  end
end
