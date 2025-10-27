# frozen_string_literal: true

# Esta migración añade la columna 'cliente_id' a la tabla 'tramites'
class AddClienteToTramites < ActiveRecord::Migration[7.0] # O la versión que uses
  def change
    # add_reference :tabla, :modelo_al_que_pertenece
    #
    # - null: false -> Un trámite NO PUEDE existir sin un cliente.
    # - foreign_key: true -> Añade la restricción de BBDD.
    # - index: true -> Crea un índice en esta columna para búsquedas rápidas.
    #
    add_reference :tramites, :cliente, null: false, foreign_key: true, index: true
  end
end
