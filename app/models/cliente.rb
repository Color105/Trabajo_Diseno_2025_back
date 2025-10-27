# app/models/cliente.rb
class Cliente < ApplicationRecord
  # --- Asociaciones ---
  has_many :tramites, dependent: :restrict_with_error
  belongs_to :user, dependent: :destroy # Es buena idea agregar dependent: :destroy

  # --- ¡¡AGREGAR ESTA LÍNEA!! ---
  accepts_nested_attributes_for :user
  # -------------------------------

  # --- Validaciones ---
  validates :nombre_apellido_cliente, presence: { message: "El nombre y apellido no pueden estar en blanco" }
  validates :mail_cliente,
            presence: { message: "El email no puede estar en blanco" },
            uniqueness: { case_sensitive: false, message: "Ya existe un cliente con este email" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "El formato del email no es válido" }
  validates :cuit_cliente,
            presence: { message: "El CUIT no puede estar en blanco" },
            uniqueness: { case_sensitive: false, message: "Ya existe un cliente con este CUIT" }
  # validates :cuit_cliente, format: { with: /\A\d{2}-\d{8}-\d{1}\z/, message: "Formato de CUIT inválido (debe ser XX-XXXXXXXX-X)" }

  # --- Callbacks ---
  before_validation :set_fecha_alta, on: :create

  private

  def set_fecha_alta
    self.fecha_hora_alta_cliente ||= Time.current
  end
end