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

ActiveRecord::Schema.define(version: 2023_07_18_212222) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username"
    t.string "domain"
    t.uuid "instance_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "owner"
    t.string "handle"
    t.string "min_id"
    t.index ["instance_id"], name: "index_accounts_on_instance_id"
    t.index ["owner", "handle"], name: "index_accounts_on_owner_and_handle", unique: true
    t.index ["owner"], name: "index_accounts_on_owner"
  end

  create_table "instances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "integer_id"
    t.string "name"
    t.text "description"
    t.string "url"
    t.string "key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "accounts", "instances"
end
