# app/controllers/tramites_controller.rb
class TramitesController < ApplicationController
  # Acepta payloads tipo { "tramite": { ... } } sin obligar al front a enviar todos los campos
  wrap_parameters :tramite, include: %i[codigo estado monto consultor_id tipo_tramite_id fecha_inicio] rescue nil

  before_action :set_tramite, only: [:update_estado]

  #========================
  # GET /tramites
  #========================
  def index
    tramites = Tramite.includes(:consultor, :tipo_tramite).all
    render json: tramites.as_json(include: [:consultor, :tipo_tramite]), status: :ok
  end

  #========================
  # POST /tramites
  #========================
  # IMPORTANTE:
  # - Ignora cualquier "estado" o "codigo" que venga del front.
  # - El modelo Tramite se encarga de setear:
  #     estado = "ingresado"
  #     codigo  autogenerado (p. ej. TR-0001)
  #========================
  def create
    safe_attrs = tramite_params.slice(:monto, :consultor_id, :tipo_tramite_id, :fecha_inicio)
    tramite = Tramite.new(safe_attrs)

    if tramite.save
      render json: tramite.as_json(include: [:consultor, :tipo_tramite]), status: :created
    else
      render json: { errors: tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  #========================
  # PATCH /tramites/:id/update_estado
  # Params admitidos:
  #   - new_state: String (estado destino)
  #   - monto:     Numeric (opcional para actualizar importe)
  #========================
  def update_estado
    old_state    = @tramite.estado
    update_attrs = {}

    if params[:monto].present?
      update_attrs[:monto] = params[:monto].to_f
    end

    new_state = params[:new_state].to_s.downcase

    if new_state.present? && new_state != old_state
      if @tramite.can_transition_to?(new_state)
        update_attrs[:estado] = new_state
      else
        valid_states = Tramite::VALID_TRANSITIONS[old_state]&.join(', ') || 'ninguna'
        return render json: {
          error:   'Transición inválida',
          details: "No se puede cambiar de '#{old_state}' a '#{new_state}'. Válidas: #{valid_states}"
        }, status: :unprocessable_entity
      end
    end

    return render(json: { message: 'No hay datos para actualizar.' }, status: :not_modified) if update_attrs.empty?

    if @tramite.update(update_attrs)
      # Registrar histórico sólo si cambió el estado
      if update_attrs.key?(:estado)
        begin
          HistoricoEstado.create!(
            tramite:         @tramite,
            estado_anterior: old_state,
            estado_nuevo:    @tramite.estado,
            fecha_cambio:    Time.current
          )
        rescue => e
          Rails.logger.error "HistoricoEstado failed: #{e.message}"
        end
      end

      message = update_attrs.key?(:estado) ? "Trámite actualizado. Nuevo estado: #{@tramite.estado}." :
                                             'Monto actualizado exitosamente.'
      render json: @tramite.as_json(include: [:consultor, :tipo_tramite]).merge(message: message), status: :ok
    else
      render json: { errors: @tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_tramite
    @tramite = Tramite.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Trámite no encontrado' }, status: :not_found
  end

  # Strong params: se permiten campos, pero en create se hace slice para ignorar estado/codigo
  def tramite_params
    allowed = %i[codigo estado monto consultor_id tipo_tramite_id fecha_inicio]
    if params.key?(:tramite)
      params.require(:tramite).permit(*allowed)
    else
      params.permit(*allowed, :new_state, :monto)
    end
  end
end
