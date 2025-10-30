# db/migrate/XXXXXXXXXXXXXX_create_versions.rb
# Crea la tabla para las versiones de TipoTramite
class CreateVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :versions do |t|
      t.references :tipo_tramite, null: false, foreign_key: true
      t.integer :nroVersion
      t.datetime :fechaHoraInicioVigencia
      t.datetime :fechaHoraFinVigencia

      t.timestamps
    end
  end
end