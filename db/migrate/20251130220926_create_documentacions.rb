class CreateDocumentacions < ActiveRecord::Migration[8.0]
  def change
    create_table :documentacions do |t|
      t.integer :cod_documentacion
      t.string :nombre_documentacion
      t.datetime :fecha_hora_baja_documentacion

      t.timestamps
    end
  end
end
