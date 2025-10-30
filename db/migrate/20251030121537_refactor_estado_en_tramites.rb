class RefactorEstadoEnTramites < ActiveRecord::Migration[7.0]
  def change
    # 1. Añade la referencia al estado_tramite
    add_reference :tramites, :estado_tramite, null: true, foreign_key: true
    
    # 2. Quita la columna de estado antigua
    remove_column :tramites, :estado, :string
    
    # 3. ¡ASEGÚRATE DE TENER ESTA LÍNEA!
    # Quita la referencia antigua a tipo_tramite
    remove_reference :tramites, :tipo_tramite, foreign_key: true
  end
end