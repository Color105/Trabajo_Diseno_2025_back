class DetallePrecioTipoTramite < ApplicationRecord
  belongs_to :lista_precio
  belongs_to :tipo_tramite

  validates :precio_tipo_tramite,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
end
