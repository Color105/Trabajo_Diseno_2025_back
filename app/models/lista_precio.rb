class ListaPrecio < ApplicationRecord
  has_many :detalle_precio_tipo_tramites, dependent: :destroy
  has_many :tipo_tramites, through: :detalle_precio_tipo_tramites

  validates :cod_lista_precio, presence: true, uniqueness: true

  def vigente?(momento = Time.current)
    (fecha_hora_desde_lista_precio.nil? || fecha_hora_desde_lista_precio <= momento) &&
      (fecha_hora_hasta_lista_precio.nil? || fecha_hora_hasta_lista_precio >= momento) &&
      fecha_hora_baja_lista_precio.nil?
  end
end
