# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < ApplicationController
      # API stateless
      protect_from_forgery with: :null_session

      # Dejar libres estas acciones
      skip_before_action :authenticate_request!, only: [:login, :register]

      def login
        user = User.find_by(email: params[:email].to_s.downcase)
        if user&.authenticate(params[:password])
          token = JsonWebToken.encode({ sub: user.id, role: user.role })
          render json: { token: token, user: user.slice(:id, :name, :email, :role) }, status: :ok
        else
          render json: { error: 'Credenciales inválidas' }, status: :unauthorized
        end
      end

      def register
        user = User.new(
          name:  params[:name],
          email: params[:email]&.downcase,
          role:  :cliente, # ajusta si usas enum/string diferente
          password: params[:password],
          password_confirmation: params[:password_confirmation]
        )

        if user.save
          token = JsonWebToken.encode({ sub: user.id, role: user.role })
          render json: { token: token, user: user.slice(:id, :name, :email, :role) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def me
        render json: { user: current_user.slice(:id, :name, :email, :role) }, status: :ok
      end
    end
  end
end
