# app/models/tipo_tramite.rb
class TipoTramite < ApplicationRecord
  # =====================
  # Relaciones
  # =====================

  # Un TipoTramite tiene muchas versiones
  has_many :versions, dependent: :destroy
  
  # Un TipoTramite tiene muchos trámites A TRAVÉS de sus versiones
  has_many :tramites, through: :versions

  # Un TipoTramite puede tener muchos precios en distintas listas
  has_many :detalle_precio_tipo_tramites, dependent: :destroy
  has_many :lista_precios, through: :detalle_precio_tipo_tramites

  # =====================
  # Validaciones
  # =====================

  validates :nombre, presence: true, uniqueness: true
  validates :plazo_documentacion, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
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
      .order(fechaHoraInicioVigencia: :desc) # La más reciente activa
      .first
  end

  # Último precio cargado para este tipo de trámite
  # Si se pasa una lista_precio, filtra por esa lista
  def precio_actual(lista_precio: nil)
    scope = detalle_precio_tipo_tramites
    scope = scope.where(lista_precio: lista_precio) if lista_precio

    scope.order(created_at: :desc).limit(1).pluck(:precio_tipo_tramite).first
  end
end
