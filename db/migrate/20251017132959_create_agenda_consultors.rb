class CreateAgendaConsultors < ActiveRecord::Migration[8.0]
  def change
    create_table :agenda_consultors do |t|
      t.datetime :fecha_hora
      t.references :consultor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
