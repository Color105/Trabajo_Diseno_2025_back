# frozen_string_literal: true

# Representa a un Cliente en el sistema.
# Este modelo almacena la información de perfil del cliente,
# mientras que el modelo 'User' (no mostrado aquí) manejaría
# la autenticación (login/password) y el rol.
#
# === Migración (Migration) Recomendada ===
#
# class CreateClientes < ActiveRecord::Migration[8.0]
#   def change
#     create_table :clientes do |t|
#       t.string :nombre_apellido_cliente, null: false
#       t.string :mail_cliente, null: false
#       t.string :cuit_cliente, null: false
#       t.string :direccion_cliente
#       t.string :telefono_cliente # Usar string para teléfonos
#       t.datetime :fecha_hora_alta_cliente
#       t.datetime :fecha_hora_baja_cliente
#
#       # Asumiendo que un Cliente está vinculado a un User (para login)
#       t.references :user, null: false, foreign_key: true
#
#       t.timestamps
#     end
#
#     # Índices para campos únicos
#     add_index :clientes, :mail_cliente, unique: true
#     add_index :clientes, :cuit_cliente, unique: true
#     add_index :clientes, :user_id, unique: true
#   end
# end
#
# === Modelo User (Recomendado) ===
#
# class User < ApplicationRecord
#   has_secure_password
#   enum role: { admin: 0, recepcionista: 1, cliente: 2 }
#
#   # Un usuario de rol 'cliente' tiene un perfil de cliente
#   has_one :cliente, dependent: :destroy
#
#   # ...
# end
#
class Cliente < ApplicationRecord
  # --- Asociaciones ---

  # Un cliente puede tener muchos trámites.
  # El diagrama indica 1..* (uno a muchos).
  #
  # A diferencia de Consultor (que usa :nullify), si un Cliente se elimina,
  # no queremos que los trámites queden "huérfanos", ya que un trámite
  # DEBE tener un cliente (según la lógica 1..*).
  #
  # Usamos :restrict_with_error para PREVENIR que un Cliente sea eliminado
  # si tiene trámites asociados. Esto fuerza al admin a gestionar
  # esos trámites primero (ej: cancelarlos).
  has_many :tramites, dependent: :restrict_with_error

  # Asumiendo que el Cliente "pertenece" a un User (que maneja el login)
  # Esto es crucial para la funcionalidad de "loguearse" que mencionaste.
  belongs_to :user

  # --- Validaciones ---
  # Basado en los campos del diagrama y la lógica de negocio

  validates :nombre_apellido_cliente, presence: { message: "El nombre y apellido no pueden estar en blanco" }

  validates :mail_cliente,
            presence: { message: "El email no puede estar en blanco" },
            uniqueness: { case_sensitive: false, message: "Ya existe un cliente con este email" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "El formato del email no es válido" }

  validates :cuit_cliente,
            presence: { message: "El CUIT no puede estar en blanco" },
            uniqueness: { case_sensitive: false, message: "Ya existe un cliente con este CUIT" }
  
  # Validación opcional para formato de CUIT (Argentina)
  # validates :cuit_cliente, format: { with: /\A\d{2}-\d{8}-\d{1}\z/, message: "Formato de CUIT inválido (debe ser XX-XXXXXXXX-X)" }


  # --- Callbacks ---
  # Asigna la fecha de alta automáticamente al crear un nuevo cliente
  before_validation :set_fecha_alta, on: :create


  # --- Atributos del Diagrama ---
  #
  # - cuit_cliente (String)
  # - direccion_cliente (String)
  # - fecha_hora_alta_cliente (Datetime)
  # - fecha_hora_baja_cliente (Datetime)
  # - mail_cliente (String)
  # - nombre_apellido_cliente (String)
  # - telefono_cliente (String - aunque el diagrama dice 'double', string es mejor)
  #

  private

  # Método privado para el callback
  def set_fecha_alta
    # Asigna la fecha y hora actual solo si no ha sido seteada previamente
    self.fecha_hora_alta_cliente ||= Time.current
  end
end

