# app/models/tramite.rb
class Tramite < ApplicationRecord
  # =======================================================
  # Asociaciones
  # =======================================================
  belongs_to :consultor
  belongs_to :tipo_tramite
  belongs_to :cliente                     # <-- ¡¡AQUÍ ESTÁ LA LÍNEA!!
  has_many   :historico_estados
  belongs_to :version_flujo, optional: true

  # =======================================================
  # DEFAULTS Y NORMALIZACIÓN
  # =======================================================
  before_validation :normalize_estado
  before_validation :apply_defaults, on: :create

  # =======================================================
  # VALIDACIONES
  # =======================================================
  validates :estado, presence: true
  validates :codigo, presence: true, uniqueness: true
  validates :cliente_id, presence: true # La base de datos lo requiere

  # =======================================================
  # Lógica de Estado y Flujo
  # =======================================================
  def estados_siguientes_posibles
    return [] unless self.version_flujo && self.estado
    self.version_flujo.transicion_flujos
        .where(estado_origen: self.estado)
        .pluck(:estado_destino)
  end

  def can_transition_to?(new_state)
    ns = new_state.to_s.downcase
    estados_siguientes_posibles.include?(ns)
  end

  def transition_to!(new_state, actor: nil, observaciones: nil, at: Time.current)
    ns = new_state.to_s.downcase.presence
    return true if ns.blank? || ns == self.estado
    raise ArgumentError, "Estado inválido: #{ns}" unless ns.present?
    raise StandardError, "Transición no permitida: #{estado} → #{ns}" unless can_transition_to?(ns)

    from = estado
    transaction do
      update!(estado: ns)
      log_historial(from: from, to: ns, actor: actor, observaciones: observaciones, at: at)
    end
    true
  rescue StandardError => e
    Rails.logger.error "Error en transition_to!: #{e.message}"
    false
  end

  private

  def normalize_estado
    self.estado = estado.to_s.downcase.presence
  end

  def apply_defaults
    self.codigo ||= generate_codigo
  end

  def generate_codigo
    last_id = Tramite.maximum(:id) || 0
    next_id = last_id + 1
    format('TR-%04d', next_id)
  end

  def log_historial(from:, to:, actor:, observaciones:, at:)
    return true unless association(:historico_estados).klass
    begin
      he = historico_estados.build
      he.estado        = to if he.respond_to?(:estado=)
      he.estado_nuevo  = to if he.respond_to?(:estado_nuevo=)
      he.estado_anterior = from if he.respond_to?(:estado_anterior=)
      he.cambiado_por  = actor.is_a?(User) ? actor.email : actor.to_s if he.respond_to?(:cambiado_por=)
      he.usuario       = actor if he.respond_to?(:usuario=)
      he.observaciones = observaciones if he.respond_to?(:observaciones=)
      he.created_at    = at if he.respond_to?(:created_at=) && he.new_record?
      he.fecha         = at if he.respond_to?(:fecha=)
      he.save if he.changed?
    rescue StandardError => e
      Rails.logger.error "Error al guardar historial: #{e.message}"
    end
    true
  end

end