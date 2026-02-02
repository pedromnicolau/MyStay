class Api::V1::PeopleController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_person, only: [ :show, :update, :destroy ]

  def index
    people = current_user.people.with_attached_profile_image.order(created_at: :desc)
    role = params[:role].presence || params[:type].presence
    role = normalize_role(role) if role
    people = filter_by_role(people, role) if role
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
  rescue ActiveRecord::InvalidForeignKey
    render_deletion_conflict_error
  end

  private

  def set_person
    @person = current_user.people.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:name, :cpf, :rg, :phone, :email, :profession, :marital_status,
                                   :city, :state, :address, :number, :neighborhood, :zip, :note, :blocked, :comments,
                                   :customer, :provider, :agent, :profile_image)
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
    if @person.customer
      Movement.where(customer_id: @person.id, tenant_id: current_tenant.id).select(:id, :check_in_date, :check_out_date)
    elsif @person.agent
      Movement.where(seller_id: @person.id, tenant_id: current_tenant.id).select(:id, :check_in_date, :check_out_date)
    else
      []
    end
  end

  def build_deletion_error_message(services_count)
    role_name = if @person.customer
      "cliente"
    elsif @person.agent
      "corretor"
    else
      "pessoa"
    end
    "Não é possível excluir este #{role_name} pois existem #{services_count} serviço(s) vinculado(s) a ele."
  end

  def normalize_role(role)
    map = {
      "Customer" => "customer",
      "Seller" => "agent",
      "Cleaner" => "provider",
      "Provider" => "provider"
    }
    map[role] || role.to_s.downcase
  end

  def filter_by_role(scope, role)
    case role
    when "customer"
      scope.where(customer: true)
    when "provider"
      scope.where(provider: true)
    when "agent"
      scope.where(agent: true)
    else
      scope
    end
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
