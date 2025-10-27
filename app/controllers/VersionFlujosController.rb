# app/controllers/version_flujos_controller.rb
class VersionFlujosController < ApplicationController
  # Buscamos el "padre" (TipoTramite) solo para las acciones anidadas (index, create)
  before_action :set_tipo_tramite, only: [:index, :create]
  # Buscamos la versión específica para 'show'
  before_action :set_version_flujo, only: [:show]

  # ---
  # GET /tipo_tramites/:tipo_tramite_id/version_flujos
  # Lista todas las versiones (históricas, vigente, futuras) para un tipo de trámite
  # ---
  def index
    @versiones = @tipo_tramite.version_flujos.order(fecha_vigencia: :desc)
    render json: @versiones, status: :ok
  end

  # ---
  # GET /version_flujos/:id
  # Muestra una versión específica (la necesitamos para editar el mapa)
  # ---
  def show
    render json: @version_flujo, status: :ok
  end

  # ---
  # POST /tipo_tramites/:tipo_tramite_id/version_flujos
  # Crea una nueva versión para un tipo de trámite
  # ---
  def create
    @version = @tipo_tramite.version_flujos.new(version_flujo_params)

    # Lógica simple para el número de versión (V1, V2, V3...)
    last_version_num = @tipo_tramite.version_flujos.maximum(:numero_version) || 0
    @version.numero_version = last_version_num + 1

    if @version.save
      # --- LÓGICA CLAVE DE COPIA ---
      # Para facilitar la vida del supervisor, copiamos las transiciones
      # de la versión anterior (si existe) a esta nueva.
      copiar_transiciones_de_version_anterior(@version, last_version_num)
      # ----------------------------

      render json: @version, status: :created
    else
      render json: { errors: @version.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_tipo_tramite
    @tipo_tramite = TipoTramite.find(params[:tipo_tramite_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Tipo de Trámite no encontrado' }, status: :not_found
  end

  def set_version_flujo
     @version_flujo = VersionFlujo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Versión de Flujo no encontrada' }, status: :not_found
  end

  def version_flujo_params
    # Pedimos 'nombre_version' y 'fecha_vigencia'
    params.require(:version_flujo).permit(:nombre_version, :fecha_vigencia)
  end

  # Método helper para copiar el flujo
  def copiar_transiciones_de_version_anterior(nueva_version, num_version_anterior)
    return if num_version_anterior == 0 # No hay nada que copiar

    version_anterior = @tipo_tramite.version_flujos.find_by(numero_version: num_version_anterior)
    return unless version_anterior

    # Preparamos un array de 'transiciones' para insertar todo en una sola consulta SQL
    transiciones_para_copiar = []
    timestamp_actual = Time.current

    version_anterior.transicion_flujos.each do |t|
      transiciones_para_copiar << {
        version_flujo_id: nueva_version.id,
        estado_origen: t.estado_origen,
        estado_destino: t.estado_destino,
        created_at: timestamp_actual,
        updated_at: timestamp_actual
      }
    end

    # Insertamos todas las transiciones copiadas de una vez
    TransicionFlujo.insert_all(transiciones_para_copiar) unless transiciones_para_copiar.empty?
  end

end # <--- ESTE 'end' ES EL IMPORTANTE