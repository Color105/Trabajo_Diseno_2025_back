# db/migrate/TIMESTAMP_create_transicion_flujos.rb
class CreateTransicionFlujos < ActiveRecord::Migration[7.0]
  def change
    create_table :transicion_flujos do |t|
      t.references :version_flujo, null: false, foreign_key: true

      # --- CAMBIO IMPORTANTE ---
      # Usamos strings en lugar de IDs.

      # 'estado_origen' puede ser nulo (para el estado inicial)
      t.string :estado_origen

      # 'estado_destino' no puede ser nulo
      t.string :estado_destino, null: false

      t.timestamps
    end

    # Agregamos índices para que las búsquedas sean rápidas
    add_index :transicion_flujos, :estado_origen
    add_index :transicion_flujos, :estado_destino
  end
end