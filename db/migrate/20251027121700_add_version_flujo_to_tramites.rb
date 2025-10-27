# db/migrate/20251027121700_add_version_flujo_to_tramites.rb
class AddVersionFlujoToTramites < ActiveRecord::Migration[7.0]
  def change
    # Asegúrate que diga null: true
    add_reference :tramites, :version_flujo, null: true, foreign_key: true
  end
end