class CreateDetallePrecioTipoTramites < ActiveRecord::Migration[8.0]
  def change
    create_table :detalle_precio_tipo_tramites do |t|
      t.references :lista_precio, null: false, foreign_key: true
      t.references :tipo_tramite, null: false, foreign_key: true
      t.decimal :precio_tipo_tramite, precision: 12, scale: 2, null: false

      t.timestamps
    end
  end
end
