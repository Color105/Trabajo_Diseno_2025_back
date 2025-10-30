class TipoTramitesController < ApplicationController
  # Utiliza 'before_action' para buscar el tipo de trámite por ID
  # antes de ejecutar los métodos show, update y destroy.
  before_action :set_tipo_tramite, only: [:show, :update, :destroy]
  
  # GET /tipo_tramites
  # Lista todos los tipos de trámites.
  def index
    @tipos_tramites = TipoTramite.all.order(:nombre)
    render json: @tipos_tramites
  end

  # GET /tipo_tramites/1
  # Muestra un tipo de trámite específico.
  def show
    render json: @tipo_tramite
  end
  
  # POST /tipo_tramites
  # Crea un nuevo tipo de trámite.
  def create
    @tipo_tramite = TipoTramite.new(tipo_tramite_params)

    if @tipo_tramite.save
      render json: @tipo_tramite, status: :created
    else
      # Devuelve un 422 con los errores de validación.
      render json: { errors: @tipo_tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PUT/PATCH /tipo_tramites/1
  # Actualiza un tipo de trámite existente.
  def update
    if @tipo_tramite.update(tipo_tramite_params)
      render json: @tipo_tramite
    else
      # Devuelve un 422 con los errores de validación.
      render json: { errors: @tipo_tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tipo_tramites/1
  # Elimina un tipo de trámite.
  def destroy
    # El modelo TipoTramite ya tiene 'dependent: :destroy' configurado 
    # para manejar la eliminación de trámites asociados.
    if @tipo_tramite.destroy
      # Éxito: código HTTP 204 No Content
      head :no_content 
    else
      # Si falla la eliminación por alguna razón.
      render json: { errors: ["No se pudo eliminar el tipo de trámite."] }, status: :unprocessable_entity
    end
  end

  private
    # Método para buscar el recurso por ID y manejar el error 404 automáticamente.
    # Es invocado por el before_action.
    def set_tipo_tramite
      # Si el registro no se encuentra, Rails lanzará ActiveRecord::RecordNotFound,
      # que por defecto se maneja como un 404 Not Found.
      @tipo_tramite = TipoTramite.find(params[:id])
    end
    
    # Parámetros fuertes (Strong Parameters)
    def tipo_tramite_params
      params.require(:tipo_tramite).permit(:nombre, :plazo_documentacion)
    end
end
