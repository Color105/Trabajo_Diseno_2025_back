# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_10_132451) do
  create_table "agenda_consultors", force: :cascade do |t|
    t.datetime "fecha_hora"
    t.integer "consultor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultor_id"], name: "index_agenda_consultors_on_consultor_id"
  end

  create_table "clientes", force: :cascade do |t|
    t.string "nombre_apellido_cliente", null: false
    t.string "mail_cliente", null: false
    t.string "cuit_cliente", null: false
    t.string "direccion_cliente"
    t.string "telefono_cliente"
    t.datetime "fecha_hora_alta_cliente"
    t.datetime "fecha_hora_baja_cliente"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cuit_cliente"], name: "index_clientes_on_cuit_cliente", unique: true
    t.index ["mail_cliente"], name: "index_clientes_on_mail_cliente", unique: true
    t.index ["user_id"], name: "index_clientes_on_user_id", unique: true
  end

  create_table "consultors", force: :cascade do |t|
    t.string "nombre"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "estado_tramites", force: :cascade do |t|
    t.string "codEstadoTramite", null: false
    t.string "nombreEstadoTramite", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "es_estado_inicial"
    t.string "color"
    t.index ["codEstadoTramite"], name: "index_estado_tramites_on_codEstadoTramite", unique: true
    t.index ["nombreEstadoTramite"], name: "index_estado_tramites_on_nombreEstadoTramite", unique: true
  end

  create_table "historico_estados", force: :cascade do |t|
    t.string "estado_anterior"
    t.string "estado_nuevo"
    t.datetime "fecha_cambio"
    t.integer "tramite_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "estado_tramite_id", null: false
    t.index ["estado_tramite_id"], name: "index_historico_estados_on_estado_tramite_id"
    t.index ["tramite_id"], name: "index_historico_estados_on_tramite_id"
  end

  create_table "tipo_tramites", force: :cascade do |t|
    t.string "nombre"
    t.integer "plazo_documentacion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tramites", force: :cascade do |t|
    t.string "codigo"
    t.datetime "fecha_inicio"
    t.decimal "monto"
    t.integer "consultor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cliente_id", null: false
    t.integer "version_id", null: false
    t.integer "estado_tramite_id"
    t.index ["cliente_id"], name: "index_tramites_on_cliente_id"
    t.index ["consultor_id"], name: "index_tramites_on_consultor_id"
    t.index ["estado_tramite_id"], name: "index_tramites_on_estado_tramite_id"
    t.index ["version_id"], name: "index_tramites_on_version_id"
  end

  create_table "transicion_posibles", force: :cascade do |t|
    t.integer "version_id", null: false
    t.integer "estado_origen_id", null: false
    t.integer "estado_siguiente_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estado_origen_id"], name: "index_transicion_posibles_on_estado_origen_id"
    t.index ["estado_siguiente_id"], name: "index_transicion_posibles_on_estado_siguiente_id"
    t.index ["version_id", "estado_origen_id", "estado_siguiente_id"], name: "idx_transicion_unica", unique: true
    t.index ["version_id"], name: "index_transicion_posibles_on_version_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.integer "role", default: 2, null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.integer "tipo_tramite_id", null: false
    t.integer "nroVersion"
    t.datetime "fechaHoraInicioVigencia"
    t.datetime "fechaHoraFinVigencia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo_tramite_id"], name: "index_versions_on_tipo_tramite_id"
  end

  add_foreign_key "agenda_consultors", "consultors"
  add_foreign_key "clientes", "users"
  add_foreign_key "historico_estados", "estado_tramites"
  add_foreign_key "historico_estados", "tramites"
  add_foreign_key "tramites", "clientes"
  add_foreign_key "tramites", "consultors"
  add_foreign_key "tramites", "estado_tramites"
  add_foreign_key "tramites", "versions"
  add_foreign_key "transicion_posibles", "estado_tramites", column: "estado_origen_id"
  add_foreign_key "transicion_posibles", "estado_tramites", column: "estado_siguiente_id"
  add_foreign_key "transicion_posibles", "versions"
  add_foreign_key "versions", "tipo_tramites"
end
