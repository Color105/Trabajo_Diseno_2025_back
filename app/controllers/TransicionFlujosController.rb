# app/controllers/transicion_flujos_controller.rb
class TransicionFlujosController < ApplicationController
  # Buscamos el "padre" (VersionFlujo) solo para 'index' y 'create'
  before_action :set_version_flujo, only: [:index, :create]
  # Buscamos la transición específica para 'destroy'
  before_action :set_transicion_flujo, only: [:destroy]

  # ---
  # GET /version_flujos/:version_flujo_id/transicion_flujos
  # Lista todas las transiciones (el mapa) de UNA versión
  # ---
  def index
    @transiciones = @version_flujo.transicion_flujos.order(:estado_origen, :estado_destino)
    # Devolvemos un formato simple que el frontend pueda dibujar/listar
    render json: @transiciones.map { |t|
      {
        id: t.id,
        origen: t.estado_origen || 'INICIO', # Mostramos 'INICIO' si el origen es nulo
        destino: t.estado_destino
      }
    }, status: :ok
  end

  # ---
  # POST /version_flujos/:version_flujo_id/transicion_flujos
  # Agrega una nueva regla al mapa (ej: de "en_proceso" a "cancelado")
  # ---
  def create
    # Normalizamos los estados (nulo si es 'inicio', minúsculas si no)
    origen_norm = params[:estado_origen].to_s.downcase
    origen_norm = nil if origen_norm.blank? || origen_norm == 'inicio'
    
    destino_norm = params[:estado_destino].to_s.downcase
    if destino_norm.blank?
       return render json: { errors: ["Estado destino no puede estar vacío"] }, status: :unprocessable_entity
    end

    @transicion = @version_flujo.transicion_flujos.new(
      estado_origen: origen_norm,
      estado_destino: destino_norm
    )

    if @transicion.save
      render json: { id: @transicion.id, origen: @transicion.estado_origen || 'INICIO', destino: @transicion.estado_destino }, status: :created
    else
      render json: { errors: @transicion.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ---
  # DELETE /transicion_flujos/:id
  # Borra una regla del mapa
  # ---
  def destroy
    @transicion.destroy
    head :no_content
  end

  private

  def set_version_flujo
    @version_flujo = VersionFlujo.find(params[:version_flujo_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Versión de Flujo no encontrada' }, status: :not_found
  end

  def set_transicion_flujo
    @transicion = TransicionFlujo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Transición no encontrada' }, status: :not_found
  end
end