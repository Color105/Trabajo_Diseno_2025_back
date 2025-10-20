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

ActiveRecord::Schema[8.0].define(version: 2025_10_17_133009) do
  create_table "agenda_consultors", force: :cascade do |t|
    t.datetime "fecha_hora"
    t.integer "consultor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultor_id"], name: "index_agenda_consultors_on_consultor_id"
  end

  create_table "consultors", force: :cascade do |t|
    t.string "nombre"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "historico_estados", force: :cascade do |t|
    t.string "estado_anterior"
    t.string "estado_nuevo"
    t.datetime "fecha_cambio"
    t.integer "tramite_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "estado"
    t.datetime "fecha_inicio"
    t.decimal "monto"
    t.integer "consultor_id", null: false
    t.integer "tipo_tramite_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultor_id"], name: "index_tramites_on_consultor_id"
    t.index ["tipo_tramite_id"], name: "index_tramites_on_tipo_tramite_id"
  end

  add_foreign_key "agenda_consultors", "consultors"
  add_foreign_key "historico_estados", "tramites"
  add_foreign_key "tramites", "consultors"
  add_foreign_key "tramites", "tipo_tramites"
end
