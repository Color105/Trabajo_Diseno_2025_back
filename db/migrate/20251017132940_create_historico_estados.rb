class CreateHistoricoEstados < ActiveRecord::Migration[8.0]
  def change
    create_table :historico_estados do |t|
      t.string :estado_anterior
      t.string :estado_nuevo
      t.datetime :fecha_cambio
      t.references :tramite, null: false, foreign_key: true

      t.timestamps
    end
  end
end
