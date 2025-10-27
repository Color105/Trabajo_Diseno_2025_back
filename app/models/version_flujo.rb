# app/models/version_flujo.rb
class VersionFlujo < ApplicationRecord
  belongs_to :tipo_tramite
  has_many :transicion_flujos, dependent: :destroy
  has_many :tramites # Los trámites que NACIERON con esta versión

  # --- LÓGICA CLAVE ---
  # Encuentra el primer estado (como string) por el que debe empezar un trámite nuevo.
  def estado_inicial
    # Busca la transición que no tiene origen (origen: nil) y devuelve el destino.
    self.transicion_flujos.find_by(estado_origen: nil)&.estado_destino
  end
end