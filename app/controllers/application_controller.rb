class ApplicationController < ActionController::API
  before_action :set_default_format
  before_action :authenticate_request!

  attr_reader :current_user

  private

  def set_default_format
    request.format = :json
  end

  def authenticate_request!
    auth = request.headers['Authorization'].to_s
    token = if auth =~ /\Abearer\s+(.+)\z/i
      Regexp.last_match(1)
    else
      auth.presence
    end
    return render json: { error: 'Token faltante' }, status: :unauthorized if token.blank?

    begin
      payload = JsonWebToken.decode(token)
      @current_user = User.find(payload[:sub])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Usuario no encontrado' }, status: :unauthorized
    rescue => e
      render json: { error: 'Token inválido', details: e.message }, status: :unauthorized
    end
  end

  def authorize_role!(*roles)
    return render json: { error: 'No autorizado' }, status: :forbidden if current_user.nil?
    return if roles.map(&:to_s).include?(current_user.role)
    render json: { error: "Rol insuficiente (se requiere #{roles.join(' / ')})" }, status: :forbidden
  end
end
