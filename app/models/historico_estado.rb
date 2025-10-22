class TipoTramite < ApplicationRecord
  # Relaciones:
  # Al usar 'dependent: :destroy', si se elimina un TipoTramite, 
  # también se eliminarán todos los trámites asociados a él.
  has_many :tramites, dependent: :destroy 

  # Validaciones
  validates :nombre, presence: true, uniqueness: true
  validates :plazo_documentacion, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
