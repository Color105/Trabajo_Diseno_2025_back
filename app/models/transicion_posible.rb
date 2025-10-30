# app/models/transicion_posible.rb
class TransicionPosible < ApplicationRecord
  belongs_to :version
  belongs_to :estado_origen, class_name: 'EstadoTramite'
  belongs_to :estado_siguiente, class_name: 'EstadoTramite'

  # Evitar duplicados: (Origen -> Siguiente) debe ser único por versión
  validates :estado_siguiente_id, uniqueness: { scope: [:version_id, :estado_origen_id] }
  
  # Evitar que un estado transicione a sí mismo (opcional)
  validate :origen_y_siguiente_no_deben_ser_iguales

  private

  def origen_y_siguiente_no_deben_ser_iguales
    if estado_origen_id == estado_siguiente_id
      errors.add(:base, "El estado de origen y siguiente no pueden ser el mismo.")
    end
  end
end