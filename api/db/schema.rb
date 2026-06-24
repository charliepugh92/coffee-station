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

ActiveRecord::Schema[8.1].define(version: 2026_06_24_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "base_categories", force: :cascade do |t|
    t.bigint "base_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customization_category_id", null: false
    t.datetime "updated_at", null: false
    t.index ["base_id", "customization_category_id"], name: "idx_base_categories_unique", unique: true
    t.index ["base_id"], name: "index_base_categories_on_base_id"
    t.index ["customization_category_id"], name: "index_base_categories_on_customization_category_id"
  end

  create_table "bases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.bigint "station_id", null: false
    t.integer "surcharge_cents"
    t.datetime "updated_at", null: false
    t.index ["station_id", "position"], name: "index_bases_on_station_id_and_position"
    t.index ["station_id"], name: "index_bases_on_station_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_comments_on_order_id"
  end

  create_table "customization_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.integer "selection_mode", default: 0, null: false
    t.bigint "station_id", null: false
    t.datetime "updated_at", null: false
    t.index ["station_id", "position"], name: "index_customization_categories_on_station_id_and_position"
    t.index ["station_id"], name: "index_customization_categories_on_station_id"
  end

  create_table "customization_options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customization_category_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.integer "surcharge_cents"
    t.datetime "updated_at", null: false
    t.index ["customization_category_id", "position"], name: "idx_on_customization_category_id_position_45504d5325"
    t.index ["customization_category_id"], name: "index_customization_options_on_customization_category_id"
  end

  create_table "menu_preset_options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customization_option_id", null: false
    t.bigint "menu_preset_id", null: false
    t.datetime "updated_at", null: false
    t.index ["customization_option_id"], name: "index_menu_preset_options_on_customization_option_id"
    t.index ["menu_preset_id", "customization_option_id"], name: "idx_preset_options_unique", unique: true
    t.index ["menu_preset_id"], name: "index_menu_preset_options_on_menu_preset_id"
  end

  create_table "menu_presets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.bigint "station_id", null: false
    t.datetime "updated_at", null: false
    t.index ["station_id", "position"], name: "index_menu_presets_on_station_id_and_position"
    t.index ["station_id"], name: "index_menu_presets_on_station_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "base_id"
    t.datetime "created_at", null: false
    t.string "guest_name", null: false
    t.string "guest_token", null: false
    t.jsonb "memory", default: {}, null: false
    t.bigint "menu_preset_id"
    t.text "notes"
    t.bigint "session_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["base_id"], name: "index_orders_on_base_id"
    t.index ["guest_token"], name: "index_orders_on_guest_token", unique: true
    t.index ["menu_preset_id"], name: "index_orders_on_menu_preset_id"
    t.index ["session_id", "status"], name: "index_orders_on_session_id_and_status"
    t.index ["session_id"], name: "index_orders_on_session_id"
  end

  create_table "push_devices", force: :cascade do |t|
    t.string "auth_key", null: false
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.string "p256dh_key", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_push_devices_on_endpoint", unique: true
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.string "auth_key"
    t.datetime "created_at", null: false
    t.string "endpoint"
    t.string "p256dh_key"
    t.bigint "push_device_id"
    t.bigint "subscriber_id", null: false
    t.string "subscriber_type", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
    t.index ["push_device_id", "subscriber_type", "subscriber_id"], name: "index_push_subscriptions_on_device_and_subscriber", unique: true
    t.index ["push_device_id"], name: "index_push_subscriptions_on_push_device_id"
    t.index ["subscriber_type", "subscriber_id"], name: "index_push_subscriptions_on_subscriber"
  end

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.integer "stars", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_ratings_on_order_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "opened_at"
    t.string "share_token", null: false
    t.bigint "station_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["share_token"], name: "index_sessions_on_share_token", unique: true
    t.index ["station_id"], name: "idx_one_open_session_per_station", unique: true, where: "(status = 0)"
    t.index ["station_id"], name: "index_sessions_on_station_id"
  end

  create_table "stations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "slug"], name: "index_stations_on_user_id_and_slug", unique: true, where: "(slug IS NOT NULL)"
    t.index ["user_id"], name: "index_stations_on_user_id"
  end

  create_table "user_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_label"
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.datetime "last_active_at"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["jti"], name: "index_user_sessions_on_jti", unique: true
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "base_categories", "bases", column: "base_id"
  add_foreign_key "base_categories", "customization_categories"
  add_foreign_key "bases", "stations"
  add_foreign_key "comments", "orders"
  add_foreign_key "customization_categories", "stations"
  add_foreign_key "customization_options", "customization_categories"
  add_foreign_key "menu_preset_options", "customization_options"
  add_foreign_key "menu_preset_options", "menu_presets"
  add_foreign_key "menu_presets", "stations"
  add_foreign_key "orders", "bases", column: "base_id", on_delete: :nullify
  add_foreign_key "orders", "menu_presets", on_delete: :nullify
  add_foreign_key "orders", "sessions"
  add_foreign_key "push_subscriptions", "push_devices", on_delete: :cascade
  add_foreign_key "ratings", "orders"
  add_foreign_key "sessions", "stations"
  add_foreign_key "stations", "users"
  add_foreign_key "user_sessions", "users"
end
