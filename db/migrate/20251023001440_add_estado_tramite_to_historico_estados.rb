class AddEstadoTramiteToHistoricoEstados < ActiveRecord::Migration[8.0]
  def change
    add_reference :historico_estados, :estado_tramite, null: false, foreign_key: true
  end
end
