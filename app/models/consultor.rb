# app/models/consultor.rb

class Consultor < ApplicationRecord
  # Relaciones
  has_many :tramites
  has_many :agenda_consultors
  
  # Validaciones
  validates :email, presence: true, uniqueness: true
  validates :nombre, presence: true
end