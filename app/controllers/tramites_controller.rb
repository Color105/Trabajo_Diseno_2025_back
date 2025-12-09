# app/controllers/tramites_controller.rb
class TramitesController < ApplicationController
  wrap_parameters :tramite,
                  include: %i[codigo monto consultor_id tipo_tramite_id fecha_inicio cliente_id],
                  format: [:json] rescue nil

  before_action :set_tramite, only: [:show, :update, :destroy, :update_estado]

  # =========================================================
  # INDEX
  # =========================================================
  def index
    base_scope = Tramite
      .includes(:cliente, :consultor, :version, :tipo_tramite, :estado_tramite,
                version: { transicion_posibles: :estado_siguiente })
      .order(created_at: :desc)

    tramites =
      case params[:filtro].to_s
      when 'eliminados'
        base_scope.eliminados
      when 'todos'
        base_scope
      else
        base_scope.activos
      end

    render json: tramites.as_json(serialization_options), status: :ok
  end

  # =========================================================
  # SHOW
  # =========================================================
  def show
    render json: @tramite.as_json(serialization_options), status: :ok
  end

  # =========================================================
  # CREATE
  # =========================================================
  def create
    tipo_tramite = TipoTramite.find_by(id: tramite_params[:tipo_tramite_id])
    return render json: { errors: ["Tipo de Trámite no encontrado"] }, status: :not_found unless tipo_tramite

    version_activa = tipo_tramite.version_activa
    return render json: { errors: ["No hay versión activa para este tipo de trámite"] }, status: :unprocessable_entity unless version_activa

    estado_inicial = EstadoTramite.find_by(nombreEstadoTramite: 'Ingresado')
    return render json: { errors: ["Estado inicial 'Ingresado' no configurado"] }, status: :internal_server_error unless estado_inicial

    # 👉 calculamos el precio vigente HOY para este tipo, según la lista de precios
    precio_vigente = tipo_tramite.precio_para(Date.current)

    if precio_vigente.nil?
      return render json: {
        errors: ["No hay precio vigente para este tipo de trámite en la lista de precios actual"]
      }, status: :unprocessable_entity
    end

    # ignoramos cualquier :monto que venga del front; el servidor manda
    safe_attrs = tramite_params.except(:tipo_tramite_id, :monto)

    tramite = Tramite.new(safe_attrs)
    tramite.version        = version_activa
    tramite.estado_tramite = estado_inicial
    tramite.monto          = precio_vigente   # 👈 queda grabado para siempre

    if tramite.save
      render json: tramite.as_json(serialization_options), status: :created
    else
      render json: { errors: tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # =========================================================
  # UPDATE
  # =========================================================
  def update
    safe_attrs = tramite_params.except(:tipo_tramite_id)

    if @tramite.update(safe_attrs)
      render json: @tramite.as_json(serialization_options), status: :ok
    else
      render json: { errors: @tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # =========================================================
  # DESTROY  (BAJA LÓGICA)
  # =========================================================
  def destroy
    @tramite.dar_de_baja!
    head :no_content
  end

  # =========================================================
  # UPDATE_ESTADO
  # =========================================================
  def update_estado
    new_state_name = params[:new_state].to_s.downcase
    new_monto = params[:monto].present? ? params[:monto].to_f : nil

    new_state_obj = nil
    if new_state_name.present?
      new_state_obj = EstadoTramite.find_by('lower(nombreEstadoTramite) = ?', new_state_name)
      if new_state_obj.nil? && new_state_name.include?('_')
        normalized_name = new_state_name.tr('_', ' ')
        new_state_obj = EstadoTramite.find_by('lower(nombreEstadoTramite) = ?', normalized_name)
      end
    end

    if new_state_name.present? && !new_state_obj
      return render json: { error: 'Estado inválido', details: "No se encontró el estado '#{params[:new_state]}'" }, status: :unprocessable_entity
    end

    no_state_change = new_state_obj.nil? || new_state_obj == @tramite.estado_tramite
    no_monto_change = new_monto.nil? || new_monto == @tramite.monto

    return render json: { message: 'Sin cambios' }, status: :not_modified if no_state_change && no_monto_change

    begin
      Tramite.transaction do
        @tramite.transition_to!(new_state_obj, actor: "Usuario Web") unless no_state_change
        @tramite.update!(monto: new_monto) unless no_monto_change
      end

      render json: @tramite.reload.as_json(serialization_options).merge(message: "Actualizado correctamente"),
             status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_tramite
    @tramite = Tramite.includes(
      :cliente, :consultor, :tipo_tramite, :estado_tramite,
      version: { transicion_posibles: :estado_siguiente }
    ).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Trámite no encontrado' }, status: :not_found
  end

  def serialization_options
    {
      include: {
        cliente: {},
        consultor: {},
        estado_tramite: {},
        # 👇 tipo_tramite manda precio_actual al front
        tipo_tramite: { methods: [:precio_actual] }
      },
      methods: [:posibles_siguientes_estados, :dado_de_baja?]
    }
  end

  def tramite_params
    params.require(:tramite).permit(:codigo, :monto, :consultor_id, :tipo_tramite_id, :fecha_inicio, :cliente_id)
  rescue ActionController::ParameterMissing
    params.permit(:new_state, :monto)
  end
end
