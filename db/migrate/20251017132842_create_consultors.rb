class CreateConsultors < ActiveRecord::Migration[8.0]
  def change
    create_table :consultors do |t|
      t.string :nombre
      t.string :email

      t.timestamps
    end
  end
end
