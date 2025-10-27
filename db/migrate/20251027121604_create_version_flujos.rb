class CreateVersionFlujos < ActiveRecord::Migration[8.0]
  def change
    create_table :version_flujos do |t|
      t.references :tipo_tramite, null: false, foreign_key: true
      t.integer :numero_version
      t.string :nombre_version
      t.date :fecha_vigencia

      t.timestamps
    end
  end
end
