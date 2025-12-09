class AddFechaHoraBajaToListasPrecios < ActiveRecord::Migration[8.0]
  def change
    # Si por alguna razón la columna ya existe, no hacer nada
    return if column_exists?(:lista_precios, :fecha_hora_baja_lista_precio)

    add_column :lista_precios, :fecha_hora_baja_lista_precio, :datetime
  end
end
