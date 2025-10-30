class AddInitialStateToEstadoTramites < ActiveRecord::Migration[8.0]
  def change
    add_column :estado_tramites, :es_estado_inicial, :boolean
  end
end
