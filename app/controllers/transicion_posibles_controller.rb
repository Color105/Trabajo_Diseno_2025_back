# app/controllers/transicion_posibles_controller.rb
class TransicionPosiblesController < ApplicationController
  # Asumo que tienes un 'before_action' para autenticar
  # before_action :authenticate_user! 
  
  # 'version_id' viene de la URL (ruta anidada)
  before_action :set_version_borrador, only: [:create] 
  
  # 'id' de la transición viene de la URL (ruta 'shallow')
  before_action :set_transicion, only: [:destroy] 

  # POST /versiones/:version_id/transiciones
  def create
    @transicion = @version.transicion_posibles.new(transicion_params)
    
    if @transicion.save
      # Devuelve la transición creada con sus IDs
      render json: @transicion, status: :created
    else
      # Devuelve los errores de validación (ej. "ya existe", "no puede ser el mismo")
      render json: { errors: @transicion.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /transiciones/:id
  def destroy
    # Validar que la transición pertenezca a una versión en borrador
    if @transicion.version.estado != 'Borrador'
      return render json: { error: 'No se puede modificar un circuito activo o archivado' }, status: :forbidden
    end

    @transicion.destroy
    head :no_content # Respuesta 204 (Sin Contenido), significa éxito
  end

  private

  # Método para buscar la versión (solo si es 'Borrador')
  def set_version_borrador
    @version = Version.find(params[:version_id])
    # Solo se puede modificar un 'borrador' (sin fecha de inicio)
    unless @version.estado == 'Borrador'
      render json: { error: 'Solo se pueden modificar circuitos en borrador' }, status: :forbidden
    end
  rescue ActiveRecord::RecordNotFound
     render json: { error: 'Versión no encontrada' }, status: :not_found
  end
  
  # Método para buscar la transición específica a borrar
  def set_transicion
    @transicion = TransicionPosible.find(params[:id])
  rescue ActiveRecord::RecordNotFound
     render json: { error: 'Transición no encontrada' }, status: :not_found
  end

  # Parámetros fuertes (Strong Params)
  def transicion_params
    # Esto debe coincidir con el payload de adminApi.js
    # { transicion_posible: { estado_origen_id: ..., estado_siguiente_id: ... } }
    params.require(:transicion_posible).permit(:estado_origen_id, :estado_siguiente_id)
  end
end