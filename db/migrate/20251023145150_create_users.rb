class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string  :name, null: false
      t.string  :email, null: false
      t.integer :role, null: false, default: 2   # 0=admin,1=recepcionista,2=cliente
      t.string  :password_digest, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
