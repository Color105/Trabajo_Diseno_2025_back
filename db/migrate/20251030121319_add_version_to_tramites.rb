class AddVersionToTramites < ActiveRecord::Migration[8.0]
  def change
    add_reference :tramites, :version, null: false, foreign_key: true
  end
end
