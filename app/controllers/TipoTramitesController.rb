class TipoTramitesController < ApplicationController
  
  # GET /tipo_tramites
  def index
    @tipos_tramites = TipoTramite.all
    render json: @tipos_tramites
  end

  # POST /tipo_tramites
  def create
    @tipo_tramite = TipoTramite.new(tipo_tramite_params)

    if @tipo_tramite.save
      render json: @tipo_tramite, status: :created
    else
      render json: @tipo_tramite.errors, status: :unprocessable_entity
    end
  end

  private
    # Parámetros fuertes
    def tipo_tramite_params
      params.require(:tipo_tramite).permit(:nombre, :plazo_documentacion)
    end
end