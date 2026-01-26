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

ActiveRecord::Schema[8.0].define(version: 2026_01_26_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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
    t.string "number"
    t.string "state"
    t.bigint "tenant_id", null: false
    t.string "profile_image"
    t.index ["city"], name: "index_people_on_city"
    t.index ["tenant_id", "cpf"], name: "index_people_on_tenant_and_cpf", unique: true
    t.index ["tenant_id", "cpf"], name: "index_people_on_tenant_id_and_cpf"
    t.index ["tenant_id", "rg"], name: "index_people_on_tenant_and_rg", unique: true, where: "((rg IS NOT NULL) AND ((rg)::text <> ''::text))"
    t.index ["tenant_id", "rg"], name: "index_people_on_tenant_id_and_rg", unique: true, where: "((rg IS NOT NULL) AND ((rg)::text <> ''::text))"
    t.index ["tenant_id"], name: "index_people_on_tenant_id"
    t.index ["type"], name: "index_people_on_type"
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
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number"
    t.integer "bedrooms", default: 0, null: false
    t.integer "bathrooms", default: 0, null: false
    t.integer "max_guests", default: 0, null: false
    t.boolean "air_conditioning", default: false, null: false
    t.boolean "wifi", default: false, null: false
    t.boolean "tv", default: false, null: false
    t.boolean "kitchen", default: false, null: false
    t.boolean "parking_included", default: false, null: false
    t.boolean "washing_machine", default: false, null: false
    t.boolean "pool", default: false, null: false
    t.boolean "barbecue_grill", default: false, null: false
    t.boolean "balcony", default: false, null: false
    t.boolean "pet_friendly", default: false, null: false
    t.boolean "wheelchair_accessible", default: false, null: false
    t.text "description"
    t.json "attachments_order", default: []
    t.bigint "tenant_id", null: false
    t.index ["active"], name: "index_properties_on_active"
    t.index ["city"], name: "index_properties_on_city"
    t.index ["tenant_id"], name: "index_properties_on_tenant_id"
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "service_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.bigint "tenant_id", null: false
    t.index ["tenant_id", "name"], name: "index_service_types_on_tenant_and_name", unique: true
    t.index ["tenant_id", "name"], name: "index_service_types_on_tenant_id_and_name"
    t.index ["tenant_id"], name: "index_service_types_on_tenant_id"
  end

  create_table "services", force: :cascade do |t|
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
    t.string "booking_reference"
    t.string "guest_name", null: false
    t.string "guest_email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "customer_id"
    t.bigint "property_id"
    t.bigint "seller_id"
    t.decimal "total_due", precision: 10, scale: 2
    t.decimal "deposit_amount", precision: 10, scale: 2
    t.decimal "final_amount", precision: 10, scale: 2
    t.decimal "balance_due", precision: 10, scale: 2
    t.decimal "total_payable", precision: 10, scale: 2
    t.decimal "total_paid", precision: 10, scale: 2
    t.decimal "balance_payable", precision: 10, scale: 2
    t.text "guest_note"
    t.text "seller_note"
    t.bigint "service_type_id"
    t.bigint "tenant_id", null: false
    t.json "attachments_order", default: []
    t.string "type", default: "Service", null: false
    t.index ["customer_id"], name: "index_services_on_customer_id"
    t.index ["property_id"], name: "index_services_on_property_id"
    t.index ["seller_id"], name: "index_services_on_seller_id"
    t.index ["service_type_id"], name: "index_services_on_service_type_id"
    t.index ["tenant_id", "booking_reference"], name: "index_services_on_tenant_and_booking_reference", unique: true
    t.index ["tenant_id", "booking_reference"], name: "index_services_on_tenant_id_and_booking_reference"
    t.index ["tenant_id"], name: "index_services_on_tenant_id"
    t.index ["type"], name: "index_services_on_type"
    t.index ["user_id"], name: "index_services_on_user_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.string "master_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["master_code"], name: "index_tenants_on_master_code", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "city"
    t.string "profile_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zip"
    t.string "address"
    t.string "number"
    t.string "neighborhood"
    t.string "state"
    t.string "cpf"
    t.bigint "tenant_id", null: false
    t.index ["cpf"], name: "index_users_on_cpf"
    t.index ["tenant_id", "email"], name: "index_users_on_tenant_and_email", unique: true
    t.index ["tenant_id", "email"], name: "index_users_on_tenant_id_and_email"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "people", "tenants"
  add_foreign_key "people", "users"
  add_foreign_key "properties", "tenants"
  add_foreign_key "properties", "users"
  add_foreign_key "service_types", "tenants"
  add_foreign_key "services", "people", column: "customer_id"
  add_foreign_key "services", "people", column: "seller_id"
  add_foreign_key "services", "properties"
  add_foreign_key "services", "service_types"
  add_foreign_key "services", "tenants"
  add_foreign_key "services", "users"
  add_foreign_key "users", "tenants"
end
