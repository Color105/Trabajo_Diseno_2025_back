# app/models/historico_estado.rb
class HistoricoEstado < ApplicationRecord
  
  # --- ESTA ES LA CORRECCIÓN ---
  # Un registro de historial PERTENECE A un trámite
  # y también PERTENECE A un estado.
  belongs_to :tramite
  belongs_to :estado_tramite # Asumiendo que tu modelo se llama EstadoTramite

  # --- VALIDACIONES ---
  # La fecha debe existir.
  validates :fecha, presence: true
  
  # El estado nuevo también.
  # (Asumimos que la columna se llama 'estado' como en tu log_historial)
  validates :estado, presence: true
end