# frozen_string_literal: true

class Cliente < ApplicationRecord
  # --- Asociaciones ---
  has_many :tramites, dependent: :restrict_with_error
  belongs_to :user, dependent: :destroy
  
  # Permite manejar los atributos del usuario desde el formulario del cliente
  accepts_nested_attributes_for :user

  # --- Validaciones ---
  validates :nombre_apellido_cliente, presence: { message: "no puede estar en blanco" }
  validates :mail_cliente,
            presence: { message: "no puede estar en blanco" },
            uniqueness: { case_sensitive: false, message: "ya está registrado" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "formato inválido" }
  validates :cuit_cliente,
            presence: { message: "no puede estar en blanco" },
            uniqueness: { case_sensitive: false, message: "ya está registrado" }

  # --- Callbacks ---
  before_validation :set_fecha_alta, on: :create

  private

  def set_fecha_alta
    self.fecha_hora_alta_cliente ||= Time.current
  end
end