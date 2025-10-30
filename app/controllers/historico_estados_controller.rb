# app/controllers/historico_estados_controller.rb

class HistoricoEstadosController < ApplicationController
  
  # GET /historico_estados (global)
  # GET /tramites/:tramite_id/historico_estados (específico)
  def index
    if params[:tramite_id].present?
      # --- CASO 2: BÚSQUEDA ESPECÍFICA ---
      # Si la URL es /tramites/123/historico_estados
      
      find_tramite_and_render_historial
      
    else
      # --- CASO 1: HISTORIAL GLOBAL ---
      # Si la URL es /historico_estados
      
      @historico_estados = HistoricoEstado.all.order(created_at: :desc)
      render json: @historico_estados, include: :tramite 
    end
  end

  private

  # Esta función es la que te pasé antes
  def find_tramite_and_render_historial
    param = params[:tramite_id]
    
    # Busca por ID (número) o por Código (texto)
    @tramite = Tramite.find_by(id: param) || Tramite.find_by(codigo: param)

    if @tramite
      # Encontramos el trámite, devolvemos su historial
      @historial = @tramite.historico_estados.order(created_at: :desc)
      render json: @historial
    else
      # No encontramos el trámite, devolvemos 404
      render json: { error: "No se encontró el trámite con ID o Código: #{param}" }, status: :not_found
    end
  end
end