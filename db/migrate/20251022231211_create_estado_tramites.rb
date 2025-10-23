# db/migrate/20251022231211_create_estado_tramites.rb

class CreateEstadoTramites < ActiveRecord::Migration[7.0] # O tu versión
  def change
    create_table :estado_tramites do |t|
      t.string :codEstadoTramite, null: false
      t.string :nombreEstadoTramite, null: false

      t.timestamps
    end
    
    # Índices para las validaciones de unicidad
    add_index :estado_tramites, :codEstadoTramite, unique: true
    add_index :estado_tramites, :nombreEstadoTramite, unique: true
  end
end