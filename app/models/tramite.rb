# app/models/tramite.rb
class Tramite < ApplicationRecord
  # =======================================================
  # ASOCIACIONES
  # =======================================================
  belongs_to :consultor, optional: true # Lo hacemos opcional por si se crea sin uno
  belongs_to :version 
  belongs_to :estado_tramite
  belongs_to :cliente
  
  has_one :tipo_tramite, through: :version 
  has_many :historico_estados

  # =======================================================
  # DEFAULTS Y VALIDACIONES
  # =======================================================
  before_validation :apply_defaults, on: :create

  validates :estado_tramite, presence: true 
  validates :version, presence: true
  validates :codigo, presence: true, uniqueness: true
  validates :cliente, presence: true 

  # =======================================================
  # LÓGICA DE ESTADOS
  # =======================================================
  
  def can_transition_to?(new_state_or_id)
    new_state_id = new_state_or_id.is_a?(EstadoTramite) ? new_state_or_id.id : new_state_or_id
    self.version.transicion_posibles.exists?(
      estado_origen_id: self.estado_tramite_id,
      estado_siguiente_id: new_state_id
    )
  end

  # --- ¡NUEVO MÉTODO AÑADIDO! ---
  # Este método devuelve la LISTA de objetos EstadoTramite
  # a los que este trámite puede transicionar DESDE su estado actual.
  def posibles_siguientes_estados
    # 1. Encontrar las transiciones posibles desde el estado actual
    transiciones = self.version.transicion_posibles.where(
      estado_origen_id: self.estado_tramite_id
    )
    
    # 2. Devolver los estados de *destino* de esas transiciones
    # Usamos 'includes' para precargar los objetos EstadoTramite
    transiciones.includes(:estado_siguiente).map(&:estado_siguiente)
  end
  # --- FIN DEL NUEVO MÉTODO ---

  def transition_to!(new_state, actor: nil, observaciones: nil, at: Time.current)
    unless new_state.is_a?(EstadoTramite)
      raise ArgumentError, "Se esperaba un objeto EstadoTramite, se recibió #{new_state.class}"
    end
    
    unless can_transition_to?(new_state)
      raise(StandardError, "Transición no permitida: #{estado_tramite.nombreEstadoTramite} → #{new_state.nombreEstadoTramite}")
    end

    from_state = self.estado_tramite
    
    transaction do
      update!(estado_tramite: new_state)
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
    # Asignación segura de atributos para el historial
    he.estado        = to if he.has_attribute?(:estado)
    he.estado_nuevo  = to if he.has_attribute?(:estado_nuevo)
    he.estado_anterior = from if he.has_attribute?(:estado_anterior)
    he.cambiado_por  = actor if he.has_attribute?(:cambiado_por)
    he.usuario       = actor if he.has_attribute?(:usuario)
    he.observaciones = observaciones if he.has_attribute?(:observaciones)
    he.fecha         = at if he.has_attribute?(:fecha)
    he.created_at    = at if he.has_attribute?(:created_at) && he.new_record?
    he.save if he.changed?
  rescue StandardError
    true # Fallo silencioso del log para no romper la transacción principal
  end
end