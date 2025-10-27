# app/models/transicion_flujo.rb
class TransicionFlujo < ApplicationRecord
  # Solo necesita saber a qué versión pertenece.
  belongs_to :version_flujo

  # Ya no necesitamos belongs_to :estado_origen / :estado_destino
end