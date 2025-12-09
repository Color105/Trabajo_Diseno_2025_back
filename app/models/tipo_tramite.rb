class TipoTramite < ApplicationRecord
  # =====================
  # Relaciones
  # =====================

  has_many :versions, dependent: :destroy
  has_many :tramites, through: :versions

  has_many :detalle_precio_tipo_tramites, dependent: :destroy
  has_many :lista_precios, through: :detalle_precio_tipo_tramites

  # =====================
  # Validaciones
  # =====================

  validates :nombre, presence: true, uniqueness: true
  validates :plazo_documentacion,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # =====================
  # Helpers de dominio
  # =====================

  # Versión activa (crucial para crear nuevos trámites)
  def version_activa
    versions
      .where(
        "fechaHoraInicioVigencia <= ? AND (fechaHoraFinVigencia IS NULL OR fechaHoraFinVigencia > ?)",
        Time.current, Time.current
      )
      .order(fechaHoraInicioVigencia: :desc)
      .first
  end

  # =====================
  # PRECIOS
  # =====================

  # Precio para una fecha dada (por defecto hoy).
  # Busca la ListaPrecio ACTIVA en esa fecha y luego el DetallePrecioTipoTramite
  # correspondiente a este tipo dentro de esa lista.
  def precio_para(fecha = Date.current)
    lista_vigente = ListaPrecio.activa_en(fecha)
    return nil unless lista_vigente

    detalle_precio_tipo_tramites
      .where(lista_precio: lista_vigente)
      .order(created_at: :desc)
      .limit(1)
      .pluck(:precio_tipo_tramite)
      .first
  end

  # Para front / JSON: “precio actual” hoy según la lista vigente
  def precio_actual
    precio_para(Date.current)
  end
end
