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

ActiveRecord::Schema[7.0].define(version: 2022_10_12_163444) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.integer "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "consultations", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "config", default: {}
  end

  create_table "events", force: :cascade do |t|
    t.integer "status", default: 0
    t.bigint "consultation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["consultation_id"], name: "index_events_on_consultation_id"
  end

  create_table "events_questions", force: :cascade do |t|
    t.integer "event_id"
    t.integer "question_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "consultation_id"
    t.index ["consultation_id"], name: "index_events_questions_on_consultation_id"
    t.index ["event_id"], name: "index_events_questions_on_event_id"
    t.index ["question_id"], name: "index_events_questions_on_question_id"
  end

  create_table "options", force: :cascade do |t|
    t.string "value"
    t.string "description"
    t.bigint "question_id", null: false
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "description"
    t.integer "status", default: 0
    t.integer "consultation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_options", default: 1
    t.index ["consultation_id"], name: "index_questions_on_consultation_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.text "fingerprint"
    t.bigint "token_id", null: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_receipts_on_question_id"
    t.index ["token_id", "question_id"], name: "index_receipts_on_token_id_and_question_id", unique: true
    t.index ["token_id"], name: "index_receipts_on_token_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.integer "role", default: 0
    t.integer "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "consultation_id", null: false
    t.integer "event_id"
    t.string "alias"
    t.integer "status", default: 1
    t.decimal "weight", default: "1.0"
    t.string "on_behalf_of"
    t.index ["consultation_id"], name: "index_tokens_on_consultation_id"
    t.index ["event_id"], name: "index_tokens_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "identifier"
    t.string "password_digest"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 1073741823
    t.datetime "created_at", precision: nil
    t.text "object_changes", limit: 1073741823
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "votes", force: :cascade do |t|
    t.string "value"
    t.text "fingerprint"
    t.integer "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "weight"
    t.string "alias"
    t.integer "event_id"
    t.index ["event_id"], name: "index_votes_on_event_id"
    t.index ["question_id"], name: "index_votes_on_question_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "events", "consultations"
  add_foreign_key "events_questions", "consultations"
  add_foreign_key "events_questions", "events"
  add_foreign_key "events_questions", "questions"
  add_foreign_key "options", "questions"
  add_foreign_key "questions", "consultations"
  add_foreign_key "receipts", "questions"
  add_foreign_key "receipts", "tokens"
  add_foreign_key "tokens", "consultations"
  add_foreign_key "tokens", "events"
  add_foreign_key "votes", "events"
  add_foreign_key "votes", "questions"
end
