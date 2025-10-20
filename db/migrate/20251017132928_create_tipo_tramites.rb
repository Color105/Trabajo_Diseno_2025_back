class CreateTipoTramites < ActiveRecord::Migration[8.0]
  def change
    create_table :tipo_tramites do |t|
      t.string :nombre
      t.integer :plazo_documentacion

      t.timestamps
    end
  end
end
