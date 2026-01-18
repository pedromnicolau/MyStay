class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  protected

  def secret_key
    Rails.application.secret_key_base
  end

  def decode_token(token)
    decoded = JWT.decode(token, secret_key)[0]
    decoded["user_id"]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    user_id = decode_token(token) if token
    @current_user = User.find_by(id: user_id)
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end
