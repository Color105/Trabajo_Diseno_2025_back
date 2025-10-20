# app/models/tramite.rb
class Tramite < ApplicationRecord
  # Asociaciones
  belongs_to :consultor
  belongs_to :tipo_tramite
  has_many   :historico_estados

  # =======================================================
  # MÁQUINA DE ESTADOS
  # =======================================================
  # Estado actual => [Estados permitidos]
  VALID_TRANSITIONS = {
    'ingresado'  => %w[asignado suspendido cancelado],
    'asignado'   => %w[en_proceso suspendido cancelado],
    'en_proceso' => %w[terminado suspendido cancelado],
    'suspendido' => %w[en_proceso cancelado],
    'terminado'  => [],
    'cancelado'  => []
  }.freeze

  VALID_STATES = VALID_TRANSITIONS.keys.freeze

  # =======================================================
  # DEFAULTS Y NORMALIZACIÓN
  # =======================================================
  before_validation :normalize_estado
  before_validation :apply_defaults, on: :create

  # =======================================================
  # VALIDACIONES
  # =======================================================
  validates :estado, presence: true, inclusion: { in: VALID_STATES }
  validates :codigo, presence: true, uniqueness: true

  # =======================================================
  # API de estado
  # =======================================================
  def can_transition_to?(new_state)
    ns = new_state.to_s.downcase
    Array(VALID_TRANSITIONS[estado]).include?(ns)
  end

  # Transiciona y (si es posible) deja registro en historico_estados
  def transition_to!(new_state, actor: nil, observaciones: nil, at: Time.current)
    ns = new_state.to_s.downcase
    raise ArgumentError, "Estado inválido: #{ns}" unless VALID_STATES.include?(ns)
    raise(StandardError, "Transición no permitida: #{estado} → #{ns}") unless can_transition_to?(ns)

    from = estado
    transaction do
      update!(estado: ns)
      log_historial(from:, to: ns, actor:, observaciones:, at:)
    end
  end

  private

  # Pone estado en minúsculas con guiones bajos (por si llega con otro formato)
  def normalize_estado
    self.estado = estado.to_s.downcase.presence
  end

  # Defaults solo al crear: estado y código
  def apply_defaults
    self.estado ||= 'ingresado'
    self.codigo ||= generate_codigo
  end

  # Genera TR-0001, TR-0002… usando el id máximo + 1 (simple y único)
  def generate_codigo
    next_id = (Tramite.maximum(:id) || 0) + 1
    format('TR-%04d', next_id)
  end

  # Intenta registrar el cambio en historico_estados si la tabla/columns existen
  def log_historial(from:, to:, actor:, observaciones:, at:)
    return unless association(:historico_estados).klass

    he = historico_estados.build
    # Set de atributos de forma segura según existan columnas
    he.estado        = to if he.has_attribute?(:estado)
    he.estado_nuevo  = to if he.has_attribute?(:estado_nuevo)
    he.estado_anterior = from if he.has_attribute?(:estado_anterior)
    he.cambiado_por  = actor if he.has_attribute?(:cambiado_por)
    he.usuario       = actor if he.has_attribute?(:usuario)
    he.observaciones = observaciones if he.has_attribute?(:observaciones)
    he.created_at    = at if he.has_attribute?(:created_at) && he.new_record?
    he.fecha         = at if he.has_attribute?(:fecha)

    # Si no hay ninguna de esas columnas, no falla: simplemente no guarda
    he.save if he.changed?
  rescue StandardError
    # No interrumpir la transición si el historial fallara
    true
  end
end
