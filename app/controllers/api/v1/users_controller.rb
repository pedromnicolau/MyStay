class Api::V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_user, only: [ :show, :update_user, :destroy ]

  def index
    users = User.where(tenant_id: current_tenant.id).with_attached_profile_image.order(created_at: :desc)
    render json: users.map { |user| format_user(user) }, status: :ok
  end

  def show
    render json: format_user(@user), status: :ok
  end

  def create
    user = User.new(user_creation_params.merge(tenant_id: current_tenant.id))
    if user.save
      render json: format_user(user), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_user
    if @user.update(user_update_params)
      render json: format_user(@user), status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    render json: { message: "Usuário removido" }, status: :ok
  rescue ActiveRecord::InvalidForeignKey => e
    render json: {
      error: "Não é possível excluir este usuário pois existem registros vinculados a ele.",
      message: "Por favor, primeiro remova ou atualize os registros relacionados antes de excluir este usuário."
    }, status: :conflict
  end

  def profile
    render json: format_user(current_user), status: :ok
  end

  def me
    render json: format_user(current_user), status: :ok
  end

  def update
    if current_user.update(user_params)
      render json: format_user(current_user), status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_me
    user = current_user
    unless user
      render json: { errors: [ "Unauthorized" ] }, status: :unauthorized and return
    end

    attrs = user_params_with_password

    if attrs[:password].present?
      current_password = attrs.delete(:current_password)
      unless current_password.present? && user.authenticate(current_password)
        render json: { errors: [ "Senha atual incorreta" ] }, status: :unprocessable_entity and return
      end
    else
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
      attrs.delete(:current_password)
    end

    if user.update(attrs)
      render json: format_user(user), status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.where(tenant_id: current_tenant.id).find(params[:id])
  end

  def user_creation_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :profile_image,
      :password,
      :password_confirmation
    )
  end

  def user_update_params
    permitted = params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :profile_image,
      :password,
      :password_confirmation
    )

    # Remove password fields if they're blank
    if permitted[:password].blank?
      permitted.delete(:password)
      permitted.delete(:password_confirmation)
    end

    permitted
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :profile_image
    )
  end

  def user_params_with_password
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :profile_image,
      :current_password,
      :password,
      :password_confirmation
    )
  end

  def authenticate_user!
    super
  end

  def current_user
    @current_user
  end

  def format_user(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      phone: user.phone,
      profile_image: user.profile_image.attached? ? url_for(user.profile_image) : nil,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
