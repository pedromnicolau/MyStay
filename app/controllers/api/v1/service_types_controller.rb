module Api
  module V1
    class ServiceTypesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      before_action :set_service_type, only: [ :show, :update, :destroy ]

      def index
        @service_types = ServiceType.all
        render json: @service_types
      end

      def show
        render json: @service_type
      end

      def create
        @service_type = ServiceType.new(service_type_params)

        if @service_type.save
          render json: @service_type, status: :created
        else
          render json: { errors: @service_type.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @service_type.update(service_type_params)
          render json: @service_type
        else
          render json: { errors: @service_type.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @service_type.destroy
        head :no_content
      end

      private

      def set_service_type
        @service_type = ServiceType.find(params[:id])
      end

      def service_type_params
        params.require(:service_type).permit(:name, :description)
      end
    end
  end
end
