class ListaPrecio < ApplicationRecord
  # =========================
  # Relaciones
  # =========================
  has_many :detalle_precio_tipo_tramites, dependent: :destroy
  has_many :tipo_tramites, through: :detalle_precio_tipo_tramites

  # =========================
  # Callbacks
  # =========================
  before_validation :normalizar_fechas_a_medianoche_local
  before_create :asignar_codigo_incremental
  # 👉 acá está la magia de la opción B
  before_create :ajustar_lista_anterior_si_corresponde

  # =========================
  # Validaciones
  # =========================
  validates :cod_lista_precio, presence: true, uniqueness: true
  validate :rango_de_fechas_valido
  validate :no_crear_totalmente_vencida, on: :create
  validate :no_solaparse_con_otras

  # =========================
  # Helpers de fechas (solo día)
  # =========================
  def fecha_desde
    fecha_hora_desde_lista_precio&.to_date
  end

  def fecha_hasta
    fecha_hora_hasta_lista_precio&.to_date
  end

  def fecha_baja
    fecha_hora_baja_lista_precio&.to_date
  end

  # =========================
  # Estado: :activa, :futura, :vencida
  # =========================
  def estado_en(fecha = Date.current)
    f = fecha.to_date

    # Si tiene baja, se considera vencida
    return "vencida" if fecha_baja && fecha_baja <= f

    if fecha_desde && f < fecha_desde
      "futura"
    elsif fecha_hasta && f > fecha_hasta
      "vencida"
    else
      "activa"
    end
  end

  def estado
    estado_en(Date.current)
  end

  def activa?(fecha = Date.current)
    estado_en(fecha) == "activa"
  end

  def futura?(fecha = Date.current)
    estado_en(fecha) == "futura"
  end

  def vencida?(fecha = Date.current)
    estado_en(fecha) == "vencida"
  end

  # Compatibilidad con lo que ya usabas:
  def vigente?(momento = Time.current)
    activa?(momento.to_date)
  end

  # Cuando se serializa a JSON, agregamos el estado calculado
  def as_json(options = {})
    super(options).merge(
      estado: estado
    )
  end

  # =========================
  # Scopes / Helpers de clase
  # =========================
  def self.activa_en(fecha = Date.current)
    f = fecha.to_date
    all.find { |lp| lp.activa?(f) }
  end

  def self.activa_hoy
    activa_en(Date.current)
  end

  def self.futuras_hoy
    all.select(&:futura?)
  end

  private

  # =========================
  # Callbacks privados
  # =========================

  # Normalizamos siempre a medianoche local, para evitar lío de zonas horarias
  def normalizar_fechas_a_medianoche_local
    %i[fecha_hora_desde_lista_precio fecha_hora_hasta_lista_precio].each do |attr|
      value = self[attr]
      next if value.blank?

      date = value.is_a?(Date) ? value : value.to_date
      self[attr] = Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
    end
  end

  # Código incremental tipo 1,2,3,...
  def asignar_codigo_incremental
    return if cod_lista_precio.present?

    ultimo = ListaPrecio.maximum(:cod_lista_precio).to_i
    self.cod_lista_precio = (ultimo + 1).to_s
  end

  # =========================
  # Opción B: encadenar listas
  # =========================
  # Si esta lista tiene fecha_desde, buscamos la lista inmediatamente anterior
  # (activa o futura) y le ajustamos la fecha_hasta = fecha_desde - 1 día.
  # Así NO hay huecos y solo hay una vigente por día.
  def ajustar_lista_anterior_si_corresponde
    return if fecha_desde.blank?

    d = fecha_desde

    anterior = ListaPrecio
                 .where(fecha_hora_baja_lista_precio: nil)
                 .where("fecha_hora_desde_lista_precio < ?", d)
                 .order(fecha_hora_desde_lista_precio: :desc)
                 .first

    return unless anterior

    nueva_fecha_hasta = d - 1.day

    # Si por algún motivo la nueva fecha_hasta quedara antes del desde de la anterior, no tocamos
    return if anterior.fecha_desde && nueva_fecha_hasta < anterior.fecha_desde

    anterior.update!(
      fecha_hora_hasta_lista_precio: Time.zone.local(
        nueva_fecha_hasta.year,
        nueva_fecha_hasta.month,
        nueva_fecha_hasta.day,
        0, 0, 0
      )
    )
  end

  # =========================
  # Validaciones personalizadas
  # =========================

  # 1) El rango tiene que tener sentido
  #    - Si hay desde y hasta: hasta debe ser estrictamente posterior a desde
  def rango_de_fechas_valido
    d = fecha_desde
    h = fecha_hasta
    return if d.blank? || h.blank?

    if h <= d
      errors.add(:fecha_hora_hasta_lista_precio,
                 'debe ser posterior a la fecha "desde" (no puede ser anterior ni el mismo día)')
    end
  end

  # 2) No permitir crear una lista completamente vencida (ambas fechas en pasado)
  def no_crear_totalmente_vencida
    hoy = Date.current
    d = fecha_desde
    h = fecha_hasta
    return unless d && h
    return unless d < hoy && h < hoy

    errors.add(:base, 'No tiene sentido crear una lista totalmente vencida (ambas fechas en el pasado)')
  end

  # 3) No solaparse con otras listas "vivas" (sin baja)
  #    OJO: igual usamos ajustar_lista_anterior_si_corresponde para encadenar,
  #    esto es por si alguien mete fechas raras.
  def no_solaparse_con_otras
    d = fecha_desde
    h = fecha_hasta
    return if d.blank? && h.blank?

    scope = ListaPrecio.where(fecha_hora_baja_lista_precio: nil)
    scope = scope.where.not(id: id) if persisted?

    scope.find_each do |otra|
      od = otra.fecha_desde
      oh = otra.fecha_hasta

      # si la otra no tiene rango definido, la ignoramos
      next if od.blank? && oh.blank?

      # interpretamos "sin hasta" como infinito
      h_eff  = h  || Date::Infinity.new
      oh_eff = oh || Date::Infinity.new

      # hay solapamiento si los rangos [d, h_eff] y [od, oh_eff] se tocan
      if d && od && d <= oh_eff && od <= h_eff
        errors.add(:base, "El rango de vigencia se solapa con la lista #{otra.cod_lista_precio}")
        break
      end
    end
  end
end
