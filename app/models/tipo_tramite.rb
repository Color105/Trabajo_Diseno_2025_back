# app/models/tipo_tramite.rb
class TipoTramite < ApplicationRecord
  # Relaciones
  has_many :tramites
  
  # --- INICIO DE LÍNEAS NUEVAS ---
  has_many :version_flujos, dependent: :destroy
  has_many :transicion_flujos, through: :version_flujos

  # --- LÓGICA CLAVE ---
  # Encuentra la versión que se debe usar HOY.
  def version_vigente
    self.version_flujos
        .where("fecha_vigencia <= ?", Date.today)
        .order(fecha_vigencia: :desc)
        .first
  end
  # --- FIN DE LÍNEAS NUEVAS ---

  # Validaciones
  validates :nombre, presence: true, uniqueness: true
  validates :plazo_documentacion, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
# app/models/tipo_tramite.rb

class TipoTramite < ApplicationRecord
  # Relaciones
  has_many :tramites

  # Validaciones
  validates :nombre, presence: true, uniqueness: true
  validates :plazo_documentacion, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
