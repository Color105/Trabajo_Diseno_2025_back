class CreateListaPrecios < ActiveRecord::Migration[8.0]
  def change
    create_table :lista_precios do |t|
      t.integer  :cod_lista_precio, null: false
      t.datetime :fecha_hora_baja_lista_precio
      t.datetime :fecha_hora_desde_lista_precio
      t.datetime :fecha_hora_hasta_lista_precio

      t.timestamps
    end

    add_index :lista_precios, :cod_lista_precio, unique: true
  end
end
