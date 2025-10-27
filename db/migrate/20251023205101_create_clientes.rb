# frozen_string_literal: true

# ESTA ES LA VERSIÓN CORREGIDA DE LA MIGRACIÓN
#
# El error 'index already exists' ocurría porque:
# 1. `t.references :user` creaba un índice para `user_id`
# 2. `add_index :clientes, :user_id, unique: true` intentaba crear OTRO.
#
# SOLUCIÓN: Hacemos todo en una sola línea (la línea 18)
#
class CreateClientes < ActiveRecord::Migration[7.0] # O la versión que uses
  def change
    create_table :clientes do |t|
      t.string :nombre_apellido_cliente, null: false
      t.string :mail_cliente, null: false
      t.string :cuit_cliente, null: false
      t.string :direccion_cliente
      t.string :telefono_cliente
      t.datetime :fecha_hora_alta_cliente
      t.datetime :fecha_hora_baja_cliente

      # --- AQUÍ ESTÁ LA CORRECCIÓN ---
      # Le decimos a `t.references` que cree el índice y que sea único.
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end

    # Índices para los otros campos únicos
    add_index :clientes, :mail_cliente, unique: true, name: 'index_clientes_on_mail_cliente'
    add_index :clientes, :cuit_cliente, unique: true, name: 'index_clientes_on_cuit_cliente'

    # --- LÍNEA ELIMINADA ---
    # Ya no necesitamos la línea duplicada que causaba el error:
    # add_index :clientes, :user_id, unique: true
  end
end

