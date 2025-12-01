# app/controllers/tramite_documentacion_controller.rb
class TramiteDocumentacionController < ApplicationController
  before_action :authenticate_request!
  before_action :set_tramite
  before_action :set_tramite_documentacion, only: [:destroy]

  # GET /tramites/:tramite_id/documentos
  def index
    docs = @tramite.tramite_documentaciones
                   .includes(:documentacion, archivo_attachment: :blob)

    render json: docs.map { |d| serialize_doc(d) }
  end

  # POST /tramites/:tramite_id/documentos
  def create
    attrs = tramite_documentacion_params

    td = @tramite.tramite_documentaciones.build
    # 👇 Si viene documentacion_id, lo uso. Si no, queda en nil (ahora está permitido).
    td.documentacion_id = attrs[:documentacion_id] if attrs[:documentacion_id].present?
    td.archivo.attach(attrs[:archivo]) if attrs[:archivo].present?

    if td.save
      render json: serialize_doc(td), status: :created
    else
      render json: { errors: td.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tramites/:tramite_id/documentos/:id
  def destroy
    @tramite_documentacion.destroy
    head :no_content
  end

  private

  def set_tramite
    @tramite = Tramite.find(params[:tramite_id])
  end

  def set_tramite_documentacion
    @tramite_documentacion = @tramite.tramite_documentaciones.find(params[:id])
  end

  def tramite_documentacion_params
    params.require(:tramite_documentacion).permit(:documentacion_id, :archivo)
  end

  def serialize_doc(td)
    {
      id: td.id, # 👈 ESTE es el ID que se va auto-incrementando
      tramite_id: td.tramite_id,
      documentacion_id: td.documentacion_id,
      documentacion_nombre: td.documentacion&.nombre_documentacion,
      fecha_hora_entrega: td.fecha_hora_entrega,
      archivo_url: td.archivo_url,
      created_at: td.created_at,
      updated_at: td.updated_at
    }
  end
end
