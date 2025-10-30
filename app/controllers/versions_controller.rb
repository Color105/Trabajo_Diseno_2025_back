# app/controllers/versions_controller.rb
class VersionsController < ApplicationController
  # Asumo que tienes un 'before_action' para autenticar
  # before_action :authenticate_user! 
  
  # ¡ACCIÓN CLAVE! Asegúrate de que :create esté aquí
  before_action :set_tipo_tramite, only: [:index, :create] 
  before_action :set_version, only: [:show, :destroy, :clonar, :activar]

  # GET /tipo_tramites/:tipo_tramite_id/versiones
  # "ver un historial de todas las versiones"
  def index
    @versiones = @tipo_tramite.versions.order(nroVersion: :desc)
    # Devolvemos cada versión junto con su estado calculado
    render json: @versiones.map { |v| v.as_json.merge(estado: v.estado) }
  end

  # GET /versions/:id
  # Muestra una versión y SU CIRCUITO (las transiciones)
  def show
    # Agrupamos las transiciones por estado de origen
    transiciones_agrupadas = @version.transicion_posibles
                                      .includes(:estado_origen, :estado_siguiente)
                                      .group_by(&:estado_origen)
                                      .map do |origen, transiciones|
                                        {
                                          estadoTramite: origen,
                                          # ¡CAMBIO! Ahora enviamos el objeto de destino Y el ID de la transición
                                          posiblesDestinos: transiciones.map do |t| 
                                            {
                                              estado: t.estado_siguiente,
                                              transicion_id: t.id # <-- ¡¡Esto es lo que necesitamos!!
                                            }
                                          end
                                        }
                                      end
    
    render json: { version: @version.as_json.merge(estado: @version.estado), circuito: transiciones_agrupadas }
  end

  # --- ¡¡ACCIÓN QUE FALTABA!! ---
  # POST /tipo_tramites/:tipo_tramite_id/versiones
  # (Crea la Versión 1 inicial)
  def create
    # @tipo_tramite es seteado por el before_action
    
    # Validar que no exista ya una v1
    if @tipo_tramite.versions.any?
      return render json: { error: "Este tipo de trámite ya tiene versiones, use 'clonar' en su lugar" }, status: :unprocessable_entity
    end

    @version = @tipo_tramite.versions.new(
      nroVersion: 1
      # fechaHoraInicioVigencia es nil -> 'Borrador'
    )

    if @version.save
      render json: @version.as_json.merge(estado: @version.estado), status: :created
    else
      render json: @version.errors, status: :unprocessable_entity
    end
  end
  # --- FIN DE LA ACCIÓN QUE FALTABA ---

  # POST /versions/:id/clonar
  # "Crea una nueva versión cada vez que modifica la última"
  def clonar
    nueva_version = nil
    ActiveRecord::Base.transaction do
      # 1. Encontrar la última versión (la que se clona)
      ultima_version = @version

      # 2. Crear nueva versión (en borrador)
      nueva_version = ultima_version.tipo_tramite.versions.new(
        nroVersion: (ultima_version.tipo_tramite.versions.maximum(:nroVersion) || 0) + 1
        # fechaHoraInicioVigencia es nil, por lo tanto es 'borrador'
      )
      
      # 3. Copiar todas las transiciones
      if nueva_version.save
        transiciones_a_copiar = ultima_version.transicion_posibles.map do |t|
          { 
            version_id: nueva_version.id, 
            estado_origen_id: t.estado_origen_id, 
            estado_siguiente_id: t.estado_siguiente_id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end
        TransicionPosible.insert_all!(transiciones_a_copiar) unless transiciones_a_copiar.empty?
      else
        raise ActiveRecord::Rollback
      end
    end
    
    if nueva_version.persisted?
      render json: nueva_version.as_json.merge(estado: nueva_version.estado), status: :created
    else
      render json: nueva_version.errors, status: :unprocessable_entity
    end
  end

  # POST /versions/:id/activar
  # "Publica" una versión borrador, poniendo fecha de inicio AHORA
  def activar
    # Solo se pueden activar versiones en borrador
    unless @version.estado == 'Borrador'
      return render json: { error: 'Solo se pueden activar versiones en borrador' }, status: :unprocessable_entity
    end

    begin
      ActiveRecord::Base.transaction do
        # 1. Poner fecha fin a la versión activa actual (si existe)
        version_activa_actual = @version.tipo_tramite.version_activa
        version_activa_actual&.update!(fechaHoraFinVigencia: Time.current)
        
        # 2. Activar la nueva versión
        @version.update!(fechaHoraInicioVigencia: Time.current, fechaHoraFinVigencia: nil)
        
        render json: @version.as_json.merge(estado: @version.estado)
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # DELETE /versions/:id
  # "dar de baja a versiones futuras" (solo las 'borrador')
  def destroy
    if @version.estado == 'Borrador'
      @version.destroy
      head :no_content
    else
      render json: { error: 'No se puede eliminar una versión activa o archivada' }, status: :unprocessable_entity
    end
  end

  private

  def set_tipo_tramite
    @tipo_tramite = TipoTramite.find(params[:tipo_tramite_id])
  end

  def set_version
    @version = Version.find(params[:id])
  end
end