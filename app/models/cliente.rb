# frozen_string_literal: true

class Cliente < ApplicationRecord
  # --- Asociaciones ---
  has_many :tramites, dependent: :restrict_with_error
  belongs_to :user, dependent: :destroy

  # Permite manejar los atributos del usuario desde el formulario del cliente
  accepts_nested_attributes_for :user

  # --- Callbacks ---
  before_validation :normalizar_campos
  before_validation :set_fecha_alta, on: :create

  # --- Validaciones de perfil ---

  # Nombre y apellido: obligatorio, solo letras/espacios, longitud razonable
  validates :nombre_apellido_cliente,
            presence:  { message: "no puede estar en blanco" },
            length:    { minimum: 3, maximum: 100, message: "debe tener entre 3 y 100 caracteres" },
            format:    { with: /\A[[:alpha:]\s]+\z/, message: "solo puede contener letras y espacios" }

  # Mail: obligatorio, único, formato válido
  validates :mail_cliente,
            presence:   { message: "no puede estar en blanco" },
            uniqueness: { case_sensitive: false, message: "ya está registrado" },
            format:     { with: URI::MailTo::EMAIL_REGEXP, message: "formato inválido" }

  # CUIT: obligatorio, único (por los 11 dígitos), con chequeo de dígito verificador
  validates :cuit_cliente,
            presence:   { message: "no puede estar en blanco" },
            uniqueness: { case_sensitive: false, message: "ya está registrado" }
  validate  :cuit_valido

  # Dirección: obligatoria, mínima longitud
  validates :direccion_cliente,
            presence: { message: "no puede estar en blanco" },
            length:   { minimum: 5, message: "es demasiado corta" }

  # Teléfono: opcional, pero si se completa debe tener entre 8 y 15 dígitos
  validates :telefono_cliente,
            allow_blank: true,
            format: { with: /\A\d{8,15}\z/, message: "debe tener entre 8 y 15 dígitos numéricos" }

  # ==========================
  #  Lógica para eliminación
  # ==========================
  #
  # Devuelve true si el cliente tiene al menos UN trámite:
  # - que NO está dado de baja (dado_de_baja = false / nil)
  # - y cuyo estado NO es final (Terminado, Suspendido, Cancelado)
  #
  def tiene_tramites_activos_no_finales?
    tramites
      .joins(:estado_tramite)
      .where(dado_de_baja: [false, nil]) # solo trámites activos (no dados de baja)
      .where.not(
        estado_tramites: {
          nombreEstadoTramite: EstadoTramite::FINALES
        }
      )
      .exists?
  end

  private

  # Normaliza mail, cuit y teléfono antes de validar
  def normalizar_campos
    self.mail_cliente            = mail_cliente.to_s.strip.downcase
    self.cuit_cliente            = cuit_cliente.to_s.gsub(/\D/, "")            # solo dígitos
    self.telefono_cliente        = telefono_cliente.to_s.gsub(/\D/, "") if telefono_cliente.present?
    self.direccion_cliente       = direccion_cliente.to_s.strip
    self.nombre_apellido_cliente = nombre_apellido_cliente.to_s.strip
  end

  def set_fecha_alta
    self.fecha_hora_alta_cliente ||= Time.current
  end

  # Valida CUIT argentino (11 dígitos + dígito verificador)
  def cuit_valido
    return if cuit_cliente.blank?

    digits = cuit_cliente.to_s.gsub(/\D/, "")
    unless digits.length == 11
      errors.add(:cuit_cliente, "debe tener 11 dígitos")
      return
    end

    nums   = digits.chars.map(&:to_i)
    pesos  = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2]

    suma  = pesos.each_with_index.sum { |p, i| p * nums[i] }
    resto = suma % 11
    dv    = 11 - resto
    dv    = 0 if dv == 11
    dv    = 9 if dv == 10

    errors.add(:cuit_cliente, "no es válido") unless dv == nums[10]
  end
end
