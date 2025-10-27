# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # API stateless: evitar CSRF por formulario
  protect_from_forgery with: :null_session

  before_action :authenticate_request!

  attr_reader :current_user

  private

  def authenticate_request!
    auth_header = request.headers['Authorization'].to_s
    token = auth_header.split(' ').last
    payload = JsonWebToken.decode(token)
    unless payload
      render json: { error: 'No autorizado' }, status: :unauthorized and return
    end

    @current_user = User.find_by(id: payload[:sub])
    unless @current_user
      render json: { error: 'No autorizado' }, status: :unauthorized and return
    end
  end
end
