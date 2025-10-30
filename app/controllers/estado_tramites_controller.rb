# app/controllers/estado_tramites_controller.rb

class EstadoTramitesController < ApplicationController
  # Se utiliza before_action para buscar el estado antes de show, update y destroy.
  before_action :set_estado_tramite, only: [:show, :update, :destroy]

  # GET /estado_tramites
  # Lista todos los estados de trámite.
  def index
    # CORRECCIÓN: Usar el nombre de columna correcto del modelo.
    @estado_tramites = EstadoTramite.all.order(:nombreEstadoTramite)
    render json: @estado_tramites
  end

  # GET /estado_tramites/:id
  # Muestra un estado de trámite específico.
  def show
    render json: @estado_tramite
  end

  # POST /estado_tramites
  # Crea un nuevo estado de trámite.
  def create
    @estado_tramite = EstadoTramite.new(estado_tramite_params)

    if @estado_tramite.save
      # CORRECCIÓN: Devolver location en 'created' es una buena práctica de API REST.
      render json: @estado_tramite, status: :created, location: @estado_tramite
    else
      # Devuelve un 422 con los errores de validación.
      render json: { errors: @estado_tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PUT/PATCH /estado_tramites/:id
  # Actualiza un estado de trámite existente.
  def update
    if @estado_tramite.update(estado_tramite_params)
      render json: @estado_tramite
    else
      # Devuelve un 422 con los errores de validación.
      render json: { errors: @estado_tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /estado_tramites/:id
  # Elimina un estado de trámite.
  def destroy
    # El modelo se encarga de las dependencias (con :restrict_with_error)
    if @estado_tramite.destroy
      # Éxito: código HTTP 204 No Content
      head :no_content 
    else
      # Si el destroy falla por una razón que no es una excepción (raro, pero posible)
      render json: { errors: @estado_tramite.errors.full_messages }, status: :unprocessable_entity
    end
  # 🛡️ MEJORA: Captura el error de :restrict_with_error
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  private
    # Método para buscar el recurso por ID.
    def set_estado_tramite
      @estado_tramite = EstadoTramite.find(params[:id])
    # 🛡️ MEJORA: Captura el error si no se encuentra el ID y devuelve 404
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Estado de trámite no encontrado" }, status: :not_found
    end
    
    # Parámetros fuertes (Strong Parameters)
    def estado_tramite_params
      # ⚠️ CORRECCIÓN CRÍTICA:
      # Permitir los campos que SÍ existen en tu modelo y que SÍ envía tu frontend.
      params.require(:estado_tramite).permit(:codEstadoTramite, :nombreEstadoTramite)
    end
end