# app/models/tramite.rb
class Tramite < ApplicationRecord
  # =======================================================
  # ASOCIACIONES (ACTUALIZADAS)
  # =======================================================
  belongs_to :consultor
  belongs_to :version 
  belongs_to :estado_tramite 
  has_one :tipo_tramite, through: :version 
  has_many :historico_estados

  # =======================================================
  # DEFAULTS Y NORMALIZACIÓN (ACTUALIZADOS)
  # =======================================================
  before_validation :apply_defaults, on: :create

  # =======================================================
  # VALIDACIONES (ACTUALIZADAS)
  # =======================================================
  validates :estado_tramite, presence: true 
  validates :version, presence: true
  validates :codigo, presence: true, uniqueness: true

  # =======================================================
  # API de estado (REFACTORIZADA)
  # =======================================================
  
  def can_transition_to?(new_state_or_id)
    new_state_id = new_state_or_id.is_a?(EstadoTramite) ? new_state_or_id.id : new_state_or_id
    self.version.transicion_posibles.exists?(
      estado_origen_id: self.estado_tramite_id,
      estado_siguiente_id: new_state_id
    )
  end

  def transition_to!(new_state, actor: nil, observaciones: nil, at: Time.current)
    unless new_state.is_a?(EstadoTramite)
      raise ArgumentError, "Se esperaba un objeto EstadoTramite, se recibió #{new_state.class}"
    end
    
    # --- ¡¡CORRECCIÓN AQUÍ!! ---
    # Usamos :nombreEstadoTramite en lugar de :nombre
    unless can_transition_to?(new_state)
      raise(StandardError, "Transición no permitida: #{estado_tramite.nombreEstadoTramite} → #{new_state.nombreEstadoTramite}")
    end

    from_state = self.estado_tramite
    
    transaction do
      update!(estado_tramite: new_state)
      
      # --- ¡¡CORRECCIÓN AQUÍ!! ---
      # Pasamos los nombres (strings) al log para que sea legible
      log_historial(from: from_state.nombreEstadoTramite, to: new_state.nombreEstadoTramite, actor:, observaciones:, at:)
    end
  end

  private

  def apply_defaults
    self.codigo ||= generate_codigo
  end

  def generate_codigo
    next_id = (Tramite.maximum(:id) || 0) + 1
    format('TR-%04d', next_id)
  end

  def log_historial(from:, to:, actor:, observaciones:, at:)
    return unless association(:historico_estados).klass
    he = historico_estados.build
    he.estado        = to if he.has_attribute?(:estado)
    he.estado_nuevo  = to if he.has_attribute?(:estado_nuevo)
    he.estado_anterior = from if he.has_attribute?(:estado_anterior)
    he.cambiado_por  = actor if he.has_attribute?(:cambiado_por)
    he.usuario       = actor if he.has_attribute?(:usuario)
    he.observaciones = observaciones if he.has_attribute?(:observaciones)
    he.created_at    = at if he.has_attribute?(:created_at) && he.new_record?
    he.fecha         = at if he.has_attribute?(:fecha)
    he.save if he.changed?
  rescue StandardError
    true
  end
end