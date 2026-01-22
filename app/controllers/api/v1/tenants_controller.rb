class Api::V1::TenantsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, only: [ :update ]
  before_action :set_current_tenant, only: [ :update ]

  def register
    # Garantir que o master_code seja explicitamente fornecido pelo usuário
    unless params.dig(:tenant, :master_code).present?
      render json: { errors: [ "Master code é obrigatório e deve ser informado pelo usuário" ] }, status: :unprocessable_entity
      return
    end

    tenant = Tenant.new(tenant_params)

    if tenant.save
      # Create user for this tenant
      user = User.new(user_params.merge(tenant_id: tenant.id))

      if user.save
        render json: {
          message: "Tenant e usuário criados com sucesso",
          tenant: format_tenant(tenant),
          user: format_user(user),
          tenantToken: encode_tenant_token(tenant.id),
          userToken: encode_user_token(user.id)
        }, status: :created
      else
        tenant.destroy
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: tenant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    tenant = Tenant.find_by(master_code: params[:master_code])

    unless tenant
      render json: { error: "Master code inválido" }, status: :unauthorized
      return
    end

    # Find user by email in this tenant
    user = User.find_by(
      tenant_id: tenant.id,
      email: params[:email]
    )

    unless user
      render json: { error: "Email ou senha inválidos" }, status: :unauthorized
      return
    end

    if user.authenticate(params[:password])
      render json: {
        message: "Login bem-sucedido",
        tenant: format_tenant(tenant),
        user: format_user(user),
        tenantToken: encode_tenant_token(tenant.id),
        userToken: encode_user_token(user.id)
      }, status: :ok
    else
      render json: { error: "Email ou senha inválidos" }, status: :unauthorized
    end
  end

  def update
    if @tenant.update(tenant_params)
      render json: format_tenant(@tenant), status: :ok
    else
      render json: { errors: @tenant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_current_tenant
    @tenant = current_tenant
  end

  def tenant_params
    params.require(:tenant).permit(:name, :master_code)
  end

  def user_params
    params.require(:user).permit(:email, :phone, :first_name, :last_name, :password, :password_confirmation)
  end

  def format_tenant(tenant)
    {
      id: tenant.id,
      name: tenant.name,
      master_code: tenant.master_code
    }
  end

  def format_user(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      phone: user.phone
    }
  end
end
