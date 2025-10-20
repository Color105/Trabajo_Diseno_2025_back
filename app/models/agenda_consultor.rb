# app/models/agenda_consultor.rb

class AgendaConsultor < ApplicationRecord
  # Relación con Consultor
  belongs_to :consultor

  # Validaciones
  validates :fecha_hora, presence: true
end