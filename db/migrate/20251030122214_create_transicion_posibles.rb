# db/migrate/XXXXXXXXXXXXXX_create_transicion_posibles.rb
# Crea la tabla para el "circuito" (flujo de estados)
class CreateTransicionPosibles < ActiveRecord::Migration[7.0]
  def change
    create_table :transicion_posibles do |t|
      t.references :version, null: false, foreign_key: true
      
      # Referencias a la tabla estado_tramites
      t.references :estado_origen, null: false, foreign_key: { to_table: :estado_tramites }
      t.references :estado_siguiente, null: false, foreign_key: { to_table: :estado_tramites }

      t.timestamps
    end

    # Índice para evitar transiciones duplicadas en una misma versión
    add_index :transicion_posibles, [:version_id, :estado_origen_id, :estado_siguiente_id], unique: true, name: 'idx_transicion_unica'
  end
end