class Api::V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, only: [ :profile, :update ]

  def profile
    render json: format_user(current_user), status: :ok
  end

  def update
    if current_user.update(user_params)
      render json: format_user(current_user), status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :phone, :country, :city, :profile_image)
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
      country: user.country,
      city: user.city,
      profile_image: user.profile_image,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
