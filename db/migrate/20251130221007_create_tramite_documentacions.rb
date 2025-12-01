class CreateTramiteDocumentacions < ActiveRecord::Migration[8.0]
  def change
    create_table :tramite_documentacions do |t|
      t.datetime :fecha_hora_entrega
      t.references :tramite, null: false, foreign_key: true
      t.references :documentacion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
