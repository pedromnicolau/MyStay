class Api::V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, only: [ :profile, :update, :me, :update_me ]

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

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :city,
      :state,
      :zip,
      :address,
      :number,
      :neighborhood,
      :profile_image
    )
  end

  def user_params_with_password
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :city,
      :state,
      :zip,
      :address,
      :number,
      :neighborhood,
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
      zip: user.zip,
      address: user.address,
      number: user.number,
      neighborhood: user.neighborhood,
      city: user.city,
      state: user.state,
      profile_image: user.profile_image,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
