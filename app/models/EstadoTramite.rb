# app/models/estado_tramite.rb
class EstadoTramite < ApplicationRecord
  
  # ⚠️ LA RELACIÓN INCORRECTA 'has_many :tramites' SE ELIMINÓ.
  
  # --- ESTA ES LA ÚNICA RELACIÓN CORRECTA ---
  # Un EstadoTramite está presente en el historial de muchos registros.
  # Usamos :restrict_with_error para evitar borrar un estado si ya está en el historial.
  has_many :historico_estados, dependent: :restrict_with_error 

  # Validaciones (Las que ya tenías y estaban bien)
  validates :nombreEstadoTramite, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :codEstadoTramite, presence: true, uniqueness: true
  
end
