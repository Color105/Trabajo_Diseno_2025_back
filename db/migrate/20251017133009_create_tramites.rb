class CreateTramites < ActiveRecord::Migration[8.0]
  def change
    create_table :tramites do |t|
      t.string :codigo
      t.string :estado
      t.datetime :fecha_inicio
      t.decimal :monto
      t.references :consultor, null: false, foreign_key: true
      t.references :tipo_tramite, null: false, foreign_key: true

      t.timestamps
    end
  end
end
