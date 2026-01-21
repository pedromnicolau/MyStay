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
    render_deletion_conflict_error
  end

  private

  def set_person
    @person = current_user.people.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:name, :cpf, :rg, :phone, :email, :profession, :marital_status,
                                   :city, :state, :address, :number, :neighborhood, :zip, :note, :blocked, :comments, :type)
  end

  def render_deletion_conflict_error
    related_services = fetch_related_services
    error_message = build_deletion_error_message(related_services.length)

    render json: {
      error: error_message,
      message: "Por favor, primeiro remova ou atualize os serviços relacionados antes de excluir este registro.",
      related_stays: format_services_for_response(related_services),
      stays_count: related_services.length
    }, status: :conflict
  end

  def fetch_related_services
    case @person.type
    when "Customer"
      Service.where(customer_id: @person.id).select(:id, :booking_reference, :guest_name, :check_in_date, :check_out_date)
    when "Seller"
      Service.where(seller_id: @person.id).select(:id, :booking_reference, :guest_name, :check_in_date, :check_out_date)
    else
      []
    end
  end

  def build_deletion_error_message(services_count)
    type_name = @person.type == "Customer" ? "cliente" : "vendedor"
    "Não é possível excluir este #{type_name} pois existem #{services_count} serviço(s) vinculado(s) a ele."
  end

  def format_services_for_response(services)
    services.map do |service|
      {
        id: service.id,
        booking_reference: service.booking_reference,
        guest_name: service.guest_name,
        check_in_date: service.check_in_date,
        check_out_date: service.check_out_date
      }
    end
  end
end
