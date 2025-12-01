# app/models/estado_tramite.rb
class EstadoTramite < ApplicationRecord
  
  # ⚠️ LA RELACIÓN INCORRECTA 'has_many :tramites' SE ELIMINÓ.
  
  # --- ESTA ES LA ÚNICA RELACIÓN CORRECTA ---
  # Un EstadoTramite está presente en el historial de muchos registros.
  # Usamos :restrict_with_error para evitar borrar un estado si ya está en el historial.
  has_many :historico_estados, dependent: :restrict_with_error 

  # ==========================
  #  Estados finales del flujo
  # ==========================
  # OJO: Los nombres deben coincidir EXACTO con como los cargás en la tabla
  FINALES = ['Terminado', 'Suspendido', 'Cancelado'].freeze

  # Scope para obtener solo los estados finales
  scope :finales, -> { where(nombreEstadoTramite: FINALES) }

  # Helper: ¿este estado es final?
  def final?
    FINALES.include?(nombreEstadoTramite)
  end

  # Validaciones 
  validates :nombreEstadoTramite,
            presence: true,
            uniqueness: true,
            length: { maximum: 100 }

  validates :codEstadoTramite,
            presence: true,
            uniqueness: true
end
