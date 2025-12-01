class AddFechaHoraBajaTramiteToTramites < ActiveRecord::Migration[8.0]
  def change
    add_column :tramites, :fecha_hora_baja_tramite, :datetime
  end
end
