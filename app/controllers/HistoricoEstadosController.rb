class HistoricoEstadosController < ApplicationController

  # GET /historico_estados
  def index
    @historico_estados = HistoricoEstado.all
    # Incluimos el trámite al que pertenece cada registro para auditoría
    render json: @historico_estados, include: :tramite 
  end
end