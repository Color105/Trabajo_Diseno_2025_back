# app/models/historico_estado.rb

class HistoricoEstado < ApplicationRecord
  # Relación con Trámite
  belongs_to :tramite

  # Validaciones
  validates :estado_anterior, presence: true
  validates :estado_nuevo, presence: true
  validates :fecha_cambio, presence: true
end