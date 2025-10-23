# app/controllers/tramites_controller.rb
class TramitesController < ApplicationController
  # Mantiene compatibilidad con payloads { tramite: { ... } } y directos
  wrap_parameters :tramite, include: %i[codigo estado monto consultor_id tipo_tramite_id fecha_inicio], format: [:json] rescue nil

  # ✅ Solo acciones que realmente existen
  before_action :set_tramite, only: [:show, :update, :destroy, :update_estado]

  #========================
  # GET /tramites
  #========================
  def index
    tramites = Tramite
      .includes(:consultor, :tipo_tramite)
      .order(created_at: :desc)

    render json: tramites.as_json(include: [:consultor, :tipo_tramite]), status: :ok
  end

  #========================
  # GET /tramites/:id
  #========================
  def show
    render json: @tramite.as_json(include: [:consultor, :tipo_tramite]), status: :ok
  end

  #========================
  # POST /tramites
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
  # PUT/PATCH /tramites/:id
  # (actualiza atributos básicos, NO estado/historial)
  #========================
  def update
    safe_attrs = tramite_params.slice(:monto, :consultor_id, :tipo_tramite_id, :fecha_inicio)

    if @tramite.update(safe_attrs)
      render json: @tramite.as_json(include: [:consultor, :tipo_tramite]), status: :ok
    else
      render json: { errors: @tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  #========================
  # DELETE /tramites/:id
  #========================
  def destroy
    @tramite.destroy
    head :no_content
  end

  #========================
  # PATCH /tramites/:id/update_estado
  # (cambia estado usando máquina de estados + opcionalmente monto)
  #========================
  def update_estado
    new_state = params[:new_state].to_s.downcase
    new_monto = params[:monto].present? ? params[:monto].to_f : nil

    no_state_change = new_state.blank? || new_state == @tramite.estado
    no_monto_change = new_monto.nil? || new_monto.to_f == @tramite.monto.to_f

    if no_state_change && no_monto_change
      return render json: { message: 'No hay cambios para actualizar.' }, status: :not_modified
    end

    begin
      Tramite.transaction do
        # transición con historial (modelo Tramite#transition_to!)
        @tramite.transition_to!(new_state, actor: "Usuario Web") unless no_state_change
        @tramite.update!(monto: new_monto)                      unless no_monto_change
      end

      message =
        if !no_state_change && !no_monto_change
          "Trámite actualizado. Nuevo estado: #{@tramite.estado}. Monto actualizado."
        elsif !no_state_change
          "Trámite actualizado. Nuevo estado: #{@tramite.estado}."
        else
          "Monto actualizado."
        end

      render json: @tramite.reload.as_json(include: [:consultor, :tipo_tramite]).merge(message: message), status: :ok

    rescue StandardError => e
      render json: { error: 'Actualización fallida', details: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_tramite
    @tramite = Tramite.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Trámite no encontrado' }, status: :not_found
  end

  # Admite payload { tramite: { ... } } o directo
  def tramite_params
    allowed = %i[codigo estado monto consultor_id tipo_tramite_id fecha_inicio]
    if params.key?(:tramite)
      params.require(:tramite).permit(*allowed)
    else
      params.permit(*allowed, :new_state, :monto)
    end
  end
end
