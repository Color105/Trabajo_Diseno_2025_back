# app/models/tipo_tramite.rb

class TipoTramite < ApplicationRecord
  # Relaciones
  has_many :tramites

  # Validaciones
  validates :nombre, presence: true, uniqueness: true
  validates :plazo_documentacion, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end