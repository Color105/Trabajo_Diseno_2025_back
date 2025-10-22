class Consultor < ApplicationRecord
  # Relaciones
  
  # 1. Manejo de Trámites: 
  # Se utiliza :nullify para anular (poner a NULL) el consultor_id en los trámites 
  # si el Consultor es eliminado. Esto conserva el trámite, pero lo deja sin consultor asignado.
  has_many :tramites, dependent: :nullify 
  
  # 2. Manejo de Agenda:
  # Se utiliza :destroy para eliminar en cascada las entradas de Agenda_consultors 
  # ya que estas entradas no son útiles sin el consultor al que se refieren.
  has_many :agenda_consultors, dependent: :destroy
  
  # Validaciones
  validates :email, presence: true, uniqueness: true
  validates :nombre, presence: true
end
