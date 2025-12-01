# frozen_string_literal: true

class Documentacion < ApplicationRecord
  # Un tipo de documentación puede estar en muchos trámites
  has_many :tramite_documentaciones, dependent: :restrict_with_error
  has_many :tramites, through: :tramite_documentaciones

  # Validaciones básicas
  validates :cod_documentacion,
            presence: true,
            uniqueness: { message: "ya está registrado" }

  validates :nombre_documentacion,
            presence: { message: "no puede estar en blanco" },
            length:   { minimum: 3, message: "es demasiado corto" }
end
