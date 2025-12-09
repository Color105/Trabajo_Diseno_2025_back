# app/controllers/lista_precios_controller.rb
class ListaPreciosController < ApplicationController
  before_action :set_lista_precio, only: [:show, :update, :baja, :detalles, :asignar_precio]

  # ========================================
  # GET /lista_precios
  # Devuelve todas las listas con su estado
  # ========================================
  def index
    listas = ListaPrecio.order(:cod_lista_precio)
    render json: listas.as_json, status: :ok
  end

  # ========================================
  # GET /lista_precios/:id
  # ========================================
  def show
    render json: @lista_precio.as_json, status: :ok
  end

  # ========================================
  # POST /lista_precios
  # Crea una nueva lista
  #
  # Body esperado:
  # {
  #   "lista_precio": {
  #     "fecha_hora_desde_lista_precio": "2025-12-04",
  #     "fecha_hora_hasta_lista_precio": "2026-01-14"   # opcional
  #   }
  # }
  # ========================================
  def create
    @lista_precio = ListaPrecio.new(lista_precio_params)

    # Código incremental
    ultimo_codigo = ListaPrecio.maximum(:cod_lista_precio).to_i
    @lista_precio.cod_lista_precio ||= (ultimo_codigo + 1).to_s

    # Si no mandan fecha_desde, la calculamos
    if @lista_precio.fecha_desde.nil?
      if ListaPrecio.exists?
        ultima = ListaPrecio
                 .where(fecha_hora_baja_lista_precio: nil)
                 .order(:fecha_hora_desde_lista_precio)
                 .last

        if ultima
          base = ultima.fecha_hasta || Date.current
          @lista_precio.fecha_hora_desde_lista_precio = base + 1.day
        end
      else
        return render json: {
          errors: ['Debe ingresar "vigencia desde" para la primera lista de precios']
        }, status: :unprocessable_entity
      end
    end

    if @lista_precio.save
      ajustar_listas_por_nueva_o_editada(@lista_precio)
      render json: @lista_precio.as_json, status: :created
    else
      render json: { errors: @lista_precio.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ========================================
  # PUT/PATCH /lista_precios/:id
  # Actualiza fechas de la lista
  # ========================================
  def update
    @lista_precio.assign_attributes(lista_precio_params)

    if @lista_precio.save
      ajustar_listas_por_nueva_o_editada(@lista_precio)
      render json: @lista_precio.as_json, status: :ok
    else
      render json: { errors: @lista_precio.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ========================================
  # PATCH /lista_precios/:id/baja
  # Baja lógica de la lista
  # - No deja dar de baja la única lista activa
  # ========================================
  def baja
    # Si esta es activa, me aseguro de que haya otra activa
    if @lista_precio.activa?
      otras_activas = ListaPrecio
                      .where.not(id: @lista_precio.id)
                      .any?(&:activa?)

      unless otras_activas
        return render json: {
          errors: ['No se puede dar de baja la única lista de precios activa. Primero cree otra lista vigente.']
        }, status: :unprocessable_entity
      end
    end

    @lista_precio.update!(fecha_hora_baja_lista_precio: Time.current)
    head :no_content
  end

  # ========================================
  # GET /lista_precios/:id/detalles
  # Devuelve los DetallePrecioTipoTramite de la lista
  # ========================================
  def detalles
    detalles = @lista_precio.detalle_precio_tipo_tramites.includes(:tipo_tramite)

    render json: detalles.map { |d|
      {
        id: d.id,
        tipo_tramite_id: d.tipo_tramite_id,
        tipo_tramite_nombre: d.tipo_tramite&.nombre,
        precio_tipo_tramite: d.precio_tipo_tramite
      }
    }, status: :ok
  end

  # ========================================
  # POST /lista_precios/:id/asignar_precio
  #
  # Body:
  # {
  #   "tipo_tramite_id": 3,
  #   "precio_tipo_tramite": 500.0
  # }
  # ========================================
  def asignar_precio
    tipo_id = params[:tipo_tramite_id] ||
              params.dig(:detalle_precio_tipo_tramite, :tipo_tramite_id)
    precio  = params[:precio_tipo_tramite] ||
              params.dig(:detalle_precio_tipo_tramite, :precio_tipo_tramite)

    unless tipo_id.present? && precio.present?
      return render json: { errors: ['tipo_tramite_id y precio_tipo_tramite son requeridos'] },
                    status: :bad_request
    end

    detalle = DetallePrecioTipoTramite.find_or_initialize_by(
      lista_precio_id: @lista_precio.id,
      tipo_tramite_id: tipo_id
    )
    detalle.precio_tipo_tramite = precio

    if detalle.save
      render json: {
        ok: true,
        id: detalle.id,
        lista_precio_id: @lista_precio.id,
        tipo_tramite_id: tipo_id,
        precio_tipo_tramite: detalle.precio_tipo_tramite
      }, status: :ok
    else
      render json: { ok: false, errors: detalle.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def set_lista_precio
    @lista_precio = ListaPrecio.find(params[:id])
  end

  def lista_precio_params
    params.require(:lista_precio).permit(
      :fecha_hora_desde_lista_precio,
      :fecha_hora_hasta_lista_precio
    )
  end

  # -------------------------------------------------
  # Ajusta otras listas cuando se crea/edita una lista
  #
  # Regla:
  # - Si la nueva lista es FUTURA, recortamos la "anterior"
  #   (activa o futura) para que su fecha_hasta sea el día
  #   anterior a la fecha_desde de la nueva.
  # -------------------------------------------------
  def ajustar_listas_por_nueva_o_editada(lista)
    desde = lista.fecha_desde
    return unless desde
    return unless lista.futura? # sólo nos interesa para futuras

    # Busco la lista anterior:
    # la que tenga fecha_desde menor y sea la más cercana.
    anterior = ListaPrecio
               .where.not(id: lista.id)
               .where(fecha_hora_baja_lista_precio: nil)
               .select { |lp| lp.fecha_desde.nil? || lp.fecha_desde < desde }
               .max_by(&:fecha_desde)

    return unless anterior

    # Si la anterior no tiene fecha_hasta o se pisa con la nueva, la corto
    if anterior.fecha_hasta.nil? || anterior.fecha_hasta >= desde
      anterior.update!(
        fecha_hora_hasta_lista_precio: (desde - 1.day)
      )
    end
  end
end
