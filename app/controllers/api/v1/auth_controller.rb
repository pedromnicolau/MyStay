class Api::V1::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def register
    user = User.new(user_params)
    if user.save
      render json: {
        message: "User registered successfully",
        user: format_user(user),
        token: encode_token(user.id)
      }, status: :created
    else
      render json: { errors: translated_errors(user) }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      render json: {
        message: "Login successful",
        user: format_user(user),
        token: encode_token(user.id)
      }, status: :ok
    else
      render json: { error: "Email ou senha inválidos" }, status: :unauthorized
    end
  end

  def verify
    token = request.headers["Authorization"]&.split(" ")&.last
    if token && decode_token(token)
      user_id = decode_token(token)
      user = User.find_by(id: user_id)
      if user
        render json: {
          message: "Token valid",
          user: format_user(user)
        }, status: :ok
      else
        render json: { error: "User not found" }, status: :not_found
      end
    else
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :first_name,
      :last_name,
      :phone,
      :country,
      :city,
      :state,
      :zip,
      :address,
      :number,
      :neighborhood,
      :profile_image
    )
  end

  def secret_key
    Rails.application.secret_key_base
  end

  def encode_token(user_id)
    JWT.encode({ user_id: user_id, exp: 7.days.from_now.to_i }, secret_key)
  end

  def decode_token(token)
    decoded = JWT.decode(token, secret_key)[0]
    decoded["user_id"]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
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
      country: user.country,
      city: user.city,
      state: user.state,
      profile_image: user.profile_image
    }
  end

  def translated_errors(user)
    user.errors.full_messages.map do |msg|
      case msg
      when /Email has already been taken/i
        "Email já está em uso"
      else
        msg
      end
    end
  end
end
