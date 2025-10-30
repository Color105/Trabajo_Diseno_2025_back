# app/controllers/tramites_controller.rb
class TramitesController < ApplicationController
  wrap_parameters :tramite, include: %i[codigo monto consultor_id tipo_tramite_id fecha_inicio cliente_id], format: [:json] rescue nil
  before_action :set_tramite, only: [:show, :update, :destroy, :update_estado]

  #========================
  # GET /tramites
  #========================
  def index
    tramites = Tramite
      .includes(:consultor, :version, :tipo_tramite, :estado_tramite) # Deberías añadir :cliente también
      .order(created_at: :desc)
    # Deberías añadir include: [..., :cliente]
    render json: tramites.as_json(include: [:consultor, :tipo_tramite, :estado_tramite]), status: :ok
  end

  #========================
  # GET /tramites/:id
  #========================
  def show
    render json: @tramite.as_json(include: [:consultor, :tipo_tramite, :estado_tramite]), status: :ok
  end

  #========================
  # POST /tramites
  #========================
  def create
    tipo_tramite = TipoTramite.find_by(id: tramite_params[:tipo_tramite_id])
    unless tipo_tramite
      return render json: { errors: ["No se encontró el Tipo de Trámite con ID #{tramite_params[:tipo_tramite_id]}"] }, status: :not_found
    end
    
    version_activa = tipo_tramite.version_activa
    unless version_activa
      return render json: { errors: ["Este tipo de trámite no tiene una versión activa. Contacte al administrador."] }, status: :unprocessable_entity
    end
    
    estado_inicial = EstadoTramite.find_by(nombreEstadoTramite: 'Ingresado')
    unless estado_inicial
      return render json: { errors: ["Error de configuración: No se encuentra el estado inicial 'Ingresado'."] }, status: :internal_server_error
    end
    
    # --- ¡¡CORRECCIÓN AQUÍ!! ---
    # Se añade :cliente_id a la lista de atributos seguros
    safe_attrs = tramite_params.slice(:monto, :consultor_id, :fecha_inicio, :cliente_id) 
    
    tramite = Tramite.new(safe_attrs)
    tramite.version = version_activa
    tramite.estado_tramite = estado_inicial
    
    if tramite.save
      render json: tramite.as_json(include: [:consultor, :tipo_tramite, :estado_tramite]), status: :created
    else
      render json: { errors: tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  #========================
  # PUT/PATCH /tramites/:id
  #========================
  def update
    # --- ¡¡CORRECCIÓN AQUÍ!! ---
    # Se añade :cliente_id
    safe_attrs = tramite_params.slice(:monto, :consultor_id, :fecha_inicio, :cliente_id)
    if @tramite.update(safe_attrs)
      render json: @tramite.as_json(include: [:consultor, :tipo_tramite, :estado_tramite]), status: :ok
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
  #========================
  def update_estado
    # ... (tu código de update_estado está bien) ...
    new_state_name = params[:new_state].to_s.downcase
    new_monto = params[:monto].present? ? params[:monto].to_f : nil

    new_state_obj = nil
    if new_state_name.present?
      new_state_obj = EstadoTramite.find_by('lower(nombreEstadoTramite) = ?', new_state_name)
      unless new_state_obj
        return render json: { error: 'Actualización fallida', details: "El estado '#{params[:new_state]}' no es válido." }, status: :unprocessable_entity
      end
    end

    no_state_change = new_state_obj.nil? || new_state_obj == @tramite.estado_tramite
    no_monto_change = new_monto.nil? || new_monto.to_f == @tramite.monto.to_f

    if no_state_change && no_monto_change
      return render json: { message: 'No hay cambios para actualizar.' }, status: :not_modified
    end

    begin
      Tramite.transaction do
        @tramite.transition_to!(new_state_obj, actor: "Usuario Web") unless no_state_change
        @tramite.update!(monto: new_monto) unless no_monto_change
      end

      new_state_name_for_message = @tramite.estado_tramite.nombreEstadoTramite
      message =
        if !no_state_change && !no_monto_change
          "Trámite actualizado. Nuevo estado: #{new_state_name_for_message}. Monto actualizado."
        elsif !no_state_change
          "Trámite actualizado. Nuevo estado: #{new_state_name_for_message}."
        else
          "Monto actualizado."
        end

      render json: @tramite.reload.as_json(include: [:consultor, :tipo_tramite, :estado_tramite]).merge(message: message), status: :ok

    rescue StandardError => e
      render json: { error: 'Actualización fallida', details: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_tramite
    @tramite = Tramite.includes(:version, :tipo_tramite, :estado_tramite).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Trámite no encontrado' }, status: :not_found
  end

  # --- ¡¡CORRECCIÓN AQUÍ!! ---
  # Se añade :cliente_id a la lista de parámetros permitidos
  def tramite_params
    allowed = %i[codigo monto consultor_id tipo_tramite_id fecha_inicio cliente_id]
    if params.key?(:tramite)
      params.require(:tramite).permit(*allowed)
    else
      params.permit(*allowed, :new_state)
    end
  end
end