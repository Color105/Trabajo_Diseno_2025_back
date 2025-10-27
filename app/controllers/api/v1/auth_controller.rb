class AuthController < ApplicationController
  skip_before_action :authenticate_request!, only: [:login, :register]

  def login
    user = User.find_by(email: params[:email].to_s.downcase)
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode({ sub: user.id, role: user.role })
      render json: { token:, user: user.slice(:id, :name, :email, :role) }, status: :ok
    else
      render json: { error: "Credenciales inválidas" }, status: :unauthorized
    end
  end

  def register
    user = User.new(
      name: params[:name],
      email: params[:email]&.downcase,
      role: :cliente,
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
    if user.save
      token = JsonWebToken.encode({ sub: user.id, role: user.role })
      render json: { token:, user: user.slice(:id, :name, :email, :role) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def me
    render json: { user: current_user.slice(:id, :name, :email, :role) }
  end
end
