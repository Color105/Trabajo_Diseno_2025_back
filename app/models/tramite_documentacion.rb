# app/models/tramite_documentacion.rb
# frozen_string_literal: true

class TramiteDocumentacion < ApplicationRecord
  belongs_to :tramite
  # 👇 Ahora opcional
  belongs_to :documentacion, optional: true

  # Archivo adjunto con Active Storage
  has_one_attached :archivo

  validates :archivo, presence: { message: "es obligatorio" }

  before_validation :set_fecha_entrega, on: :create

  # URL para consumir desde el front
  def archivo_url
    return nil unless archivo.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      archivo,
      only_path: true
    )
  end

  private

  def set_fecha_entrega
    self.fecha_hora_entrega ||= Time.current
  end
end
