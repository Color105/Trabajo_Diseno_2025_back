# app/models/tipo_tramite.rb
class TipoTramite < ApplicationRecord
  # Relaciones
  # Un TipoTramite tiene muchas versiones
  has_many :versions, dependent: :destroy
  
  # Un TipoTramite tiene muchos trámites A TRAVÉS de sus versiones
  has_many :tramites, through: :versions

  # Validaciones
  validates :nombre, presence: true, uniqueness: true
  validates :plazo_documentacion, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # Helper para encontrar la versión activa (crucial para crear nuevos trámites)
  def version_activa
    versions.where("fechaHoraInicioVigencia <= ? AND (fechaHoraFinVigencia IS NULL OR fechaHoraFinVigencia > ?)", Time.current, Time.current)
            .order(fechaHoraInicioVigencia: :desc) # La más reciente activa
            .first
  end
end