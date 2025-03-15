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

ActiveRecord::Schema[7.1].define(version: 2025_03_15_100114) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "interests", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "property_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["property_id"], name: "idx_16517_index_interests_on_property_id"
    t.index ["user_id", "property_id"], name: "idx_16517_index_interests_on_user_id_and_property_id", unique: true
    t.index ["user_id"], name: "idx_16517_index_interests_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "sender_id"
    t.bigint "receiver_id"
    t.bigint "property_id"
    t.text "content"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.bigint "parent_message_id"
    t.boolean "read", default: false
    t.index ["parent_message_id"], name: "idx_16501_index_messages_on_parent_message_id"
    t.index ["property_id"], name: "idx_16501_index_messages_on_property_id"
    t.index ["receiver_id"], name: "idx_16501_index_messages_on_receiver_id"
    t.index ["sender_id"], name: "idx_16501_index_messages_on_sender_id"
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "user_id"
    t.text "title"
    t.text "description"
    t.decimal "price"
    t.text "contract_file"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.json "images", default: []
    t.text "street_address"
    t.text "city"
    t.text "state"
    t.text "zip_code"
    t.index ["user_id"], name: "idx_16509_index_properties_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "email"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.text "encrypted_password", default: ""
    t.text "reset_password_token"
    t.timestamptz "reset_password_sent_at"
    t.timestamptz "remember_created_at"
    t.text "profile_photo"
    t.text "name", default: ""
    t.text "role", default: "both"
    t.text "state"
    t.text "states", default: [], array: true
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "idx_16522_index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "idx_16522_index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "interests", "properties", name: "interests_property_id_fkey"
  add_foreign_key "interests", "users", name: "interests_user_id_fkey"
  add_foreign_key "messages", "messages", column: "parent_message_id", name: "messages_parent_message_id_fkey"
  add_foreign_key "messages", "properties", name: "messages_property_id_fkey"
  add_foreign_key "messages", "users", column: "receiver_id", name: "messages_receiver_id_fkey"
  add_foreign_key "messages", "users", column: "sender_id", name: "messages_sender_id_fkey"
  add_foreign_key "properties", "users", name: "properties_user_id_fkey"
end
