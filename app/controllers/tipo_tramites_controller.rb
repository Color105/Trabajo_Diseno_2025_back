# app/controllers/tipo_tramites_controller.rb
class TipoTramitesController < ApplicationController
  # Busca el tipo de trámite antes de estas acciones
  before_action :set_tipo_tramite, only: [:show, :update, :destroy, :asignar_precio]
  
  # GET /tipo_tramites
  # Lista todos los tipos de trámites.
  def index
    @tipos_tramites = TipoTramite.all.order(:nombre)

    # Incluimos método precio_actual en el JSON
    render json: @tipos_tramites.as_json(methods: [:precio_actual])
  end

  # GET /tipo_tramites/1
  # Muestra un tipo de trámite específico.
  def show
    # Incluimos método precio_actual en el JSON
    render json: @tipo_tramite.as_json(methods: [:precio_actual])
  end
  
  # POST /tipo_tramites
  # Crea un nuevo tipo de trámite.
  def create
    @tipo_tramite = TipoTramite.new(tipo_tramite_params)

    if @tipo_tramite.save
      render json: @tipo_tramite.as_json(methods: [:precio_actual]), status: :created
    else
      render json: { errors: @tipo_tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PUT/PATCH /tipo_tramites/1
  # Actualiza un tipo de trámite existente.
  def update
    if @tipo_tramite.update(tipo_tramite_params)
      render json: @tipo_tramite.as_json(methods: [:precio_actual])
    else
      render json: { errors: @tipo_tramite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tipo_tramites/1
  # Elimina un tipo de trámite.
  def destroy
    if @tipo_tramite.destroy
      head :no_content 
    else
      render json: { errors: ["No se pudo eliminar el tipo de trámite."] }, status: :unprocessable_entity
    end
  end

  # POST /tipo_tramites/:id/asignar_precio
  #
  # Asigna (o actualiza) un precio para este TipoTramite dentro de una ListaPrecio.
  # Espera un JSON así:
  #   { "precio_tipo_tramite": 15000.50 }
  #
  def asignar_precio
    # Leer el precio desde el body (plano o anidado)
    precio_param = params[:precio_tipo_tramite] ||
                   params.dig(:detalle_precio_tipo_tramite, :precio_tipo_tramite)

    unless precio_param.present?
      render json: { ok: false, errors: ["precio_tipo_tramite es requerido"] },
             status: :bad_request and return
    end

    # Por ahora usamos una única lista (ej: lista 1)
    lista = ListaPrecio.find_or_create_by!(cod_lista_precio: 1) do |lp|
      lp.fecha_hora_desde_lista_precio = Time.current
    end

    # Busca el detalle existente para esa lista y tipoTramite, o lo crea
    detalle = DetallePrecioTipoTramite.find_or_initialize_by(
      tipo_tramite: @tipo_tramite,
      lista_precio: lista
    )

    detalle.precio_tipo_tramite = precio_param

    if detalle.save
      render json: {
        ok: true,
        tipo_tramite_id: @tipo_tramite.id,
        lista_precio_id: lista.id,
        precio: detalle.precio_tipo_tramite
      }, status: :ok
    else
      render json: {
        ok: false,
        errors: detalle.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

    def set_tipo_tramite
      @tipo_tramite = TipoTramite.find(params[:id])
    end
    
    # Parámetros fuertes (Strong Parameters)
    def tipo_tramite_params
      params.require(:tipo_tramite).permit(:nombre, :plazo_documentacion)
    end
end
