class ConsultorsController < ApplicationController
  # Llama a set_consultor antes de los métodos show, update y destroy
  # Esto asegura que @consultor esté cargado o que se devuelva un 404 si no se encuentra.
  before_action :set_consultor, only: [:show, :update, :destroy]

  # GET /consultors
  # Lista todos los consultores.
  def index
    @consultors = Consultor.all.order(:nombre)
    render json: @consultors
  end

  # GET /consultors/:id
  # Muestra un consultor específico.
  def show
    render json: @consultor
  end

  # POST /consultors
  # Crea un nuevo consultor.
  def create
    @consultor = Consultor.new(consultor_params)

    if @consultor.save
      render json: @consultor, status: :created
    else
      # Devuelve un 422 con los errores de validación.
      render json: { errors: @consultor.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PUT/PATCH /consultors/:id
  # Actualiza un consultor existente.
  def update
    if @consultor.update(consultor_params)
      render json: @consultor
    else
      # Devuelve un 422 con los errores de validación.
      render json: { errors: @consultor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /consultors/:id
  # Elimina un consultor.
  def destroy
    # Se ejecuta la eliminación. El modelo ya maneja las dependencias (:destroy o :nullify).
    if @consultor.destroy
      # Éxito: código HTTP 204 No Content (no hay cuerpo de respuesta)
      head :no_content 
    else
      # Si falla la eliminación por alguna razón (ej. validación compleja antes de eliminar).
      render json: { errors: ["No se pudo eliminar el consultor."] }, status: :unprocessable_entity
    end
  end

  private
    # Método para buscar el recurso por ID (usado por before_action).
    def set_consultor
      # Si el registro no se encuentra, Rails lanza ActiveRecord::RecordNotFound,
      # que por defecto se maneja como un 404 Not Found.
      @consultor = Consultor.find(params[:id])
    end
    
    # Parámetros fuertes (Strong Parameters)
    def consultor_params
      params.require(:consultor).permit(:nombre, :email)
    end
end
