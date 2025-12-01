class MakeDocumentacionIdNullableInTramiteDocumentacions < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tramite_documentacions, :documentacion_id, true
  end
end
