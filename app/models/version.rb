# app/models/version.rb
class Version < ApplicationRecord
  belongs_to :tipo_tramite
  has_many :transicion_posibles, dependent: :destroy
  has_many :tramites

  # Validaciones
  validates :nroVersion, presence: true, uniqueness: { scope: :tipo_tramite_id }
  
  # Lógica para determinar el estado de la versión
  def estado
    now = Time.current
    if fechaHoraInicioVigencia.nil?
      'Borrador'
    elsif fechaHoraInicioVigencia <= now && (fechaHoraFinVigencia.nil? || fechaHoraFinVigencia > now)
      'Activo'
    elsif fechaHoraInicioVigencia > now
      'Programado'
    else
      'Archivado'
    end
  end
end