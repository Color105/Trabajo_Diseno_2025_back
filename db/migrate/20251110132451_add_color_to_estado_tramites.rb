class AddColorToEstadoTramites < ActiveRecord::Migration[8.0]
  def change
    add_column :estado_tramites, :color, :string
  end
end
