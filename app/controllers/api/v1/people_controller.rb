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
  end

  private

  def set_person
    @person = current_user.people.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:name, :cpf, :rg, :phone, :email, :profession, :marital_status,
                                   :city, :address, :neighborhood, :zip, :note, :blocked, :comments, :type)
  end
end
