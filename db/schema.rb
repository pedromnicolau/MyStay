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

ActiveRecord::Schema[8.0].define(version: 2026_01_18_211100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "people", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "cpf", null: false
    t.string "rg"
    t.string "phone", null: false
    t.string "email"
    t.string "profession"
    t.string "marital_status"
    t.string "city"
    t.string "address"
    t.string "neighborhood"
    t.string "zip"
    t.string "note"
    t.boolean "blocked", default: false
    t.text "comments"
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_people_on_city"
    t.index ["type"], name: "index_people_on_type"
    t.index ["user_id", "cpf"], name: "index_people_on_user_id_and_cpf", unique: true
    t.index ["user_id"], name: "index_people_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "address"
    t.string "neighborhood"
    t.string "zip"
    t.string "city"
    t.string "state"
    t.string "image"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_properties_on_active"
    t.index ["city"], name: "index_properties_on_city"
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "stays", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "property_name", null: false
    t.string "property_type"
    t.date "check_in_date", null: false
    t.date "check_out_date", null: false
    t.integer "number_of_guests"
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.decimal "price_per_night", precision: 10, scale: 2
    t.decimal "total_price", precision: 10, scale: 2
    t.string "currency", default: "USD"
    t.text "description"
    t.string "address"
    t.text "amenities"
    t.string "status", default: "pending"
    t.string "booking_reference"
    t.string "guest_name", null: false
    t.string "guest_email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_reference"], name: "index_stays_on_booking_reference", unique: true
    t.index ["status"], name: "index_stays_on_status"
    t.index ["user_id"], name: "index_stays_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "country"
    t.string "city"
    t.string "profile_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "people", "users"
  add_foreign_key "properties", "users"
  add_foreign_key "stays", "users"
end
