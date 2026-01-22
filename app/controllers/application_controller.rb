class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  protected

  def secret_key
    Rails.application.secret_key_base
  end

  def tenant_secret_key
    Rails.application.secret_key_base.reverse
  end

  def encode_user_token(user_id)
    JWT.encode({ user_id: user_id, exp: 7.days.from_now.to_i }, secret_key)
  end

  def encode_tenant_token(tenant_id)
    JWT.encode({ tenant_id: tenant_id, exp: 7.days.from_now.to_i }, tenant_secret_key)
  end

  def decode_token(token)
    decoded = JWT.decode(token, secret_key)[0]
    # Convert to integer if needed, JWT stores as integer
    value = decoded["user_id"]
    value.is_a?(Integer) ? value : value&.to_i
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def decode_tenant_token(token)
    decoded = JWT.decode(token, tenant_secret_key)[0]
    # Convert to integer if needed, JWT stores as integer
    value = decoded["tenant_id"]
    value.is_a?(Integer) ? value : value&.to_i
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def authenticate_tenant!
    token = request.headers["Tenant-Authorization"]&.split(" ")&.last
    tenant_id = decode_tenant_token(token) if token
    @current_tenant = Tenant.find_by(id: tenant_id)
    render json: { error: "Tenant Unauthorized" }, status: :unauthorized unless @current_tenant
  end

  def authenticate_user!
    user_token = request.headers["Authorization"]&.split(" ")&.last
    tenant_token = request.headers["Tenant-Authorization"]&.split(" ")&.last

    user_id = decode_token(user_token) if user_token
    tenant_id = decode_tenant_token(tenant_token) if tenant_token

    @current_user = User.find_by(id: user_id)
    @current_tenant = Tenant.find_by(id: tenant_id)

    unless @current_user && @current_tenant && @current_user.tenant_id == @current_tenant.id
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end
  end

  def current_user
    @current_user
  end

  def current_tenant
    @current_tenant
  end
end
