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

ActiveRecord::Schema.define(version: 2023_12_05_161521) do

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

  create_table "channel_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "channel_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["channel_id"], name: "index_channel_accounts_on_channel_id"
    t.index ["user_id"], name: "index_channel_accounts_on_user_id"
  end

  create_table "channels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "hidden", default: true
    t.uuid "owner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "icon", default: ""
    t.integer "fy_engagement_threshold", default: 0
    t.index ["owner_id"], name: "index_channels_on_owner_id"
  end

  create_table "follows", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "user_id", null: false
    t.uuid "target_user_id", null: false
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

  create_table "subscribes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "channel_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["channel_id"], name: "index_subscribes_on_channel_id"
    t.index ["user_id"], name: "index_subscribes_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username"
    t.string "domain"
    t.boolean "discoverable"
    t.string "display_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "domain_id", null: false
    t.integer "following_count", default: 0
    t.integer "followers_count", default: 0
    t.boolean "local", default: false
    t.jsonb "for_you_settings", default: {}, null: false
    t.boolean "personalize", default: false
    t.bigint "last_active"
    t.index ["username", "domain"], name: "index_users_on_username_and_domain", unique: true
  end

  add_foreign_key "accounts", "instances"
  add_foreign_key "channel_accounts", "channels", on_delete: :cascade
  add_foreign_key "channel_accounts", "users", on_delete: :cascade
  add_foreign_key "channels", "users", column: "owner_id"
  add_foreign_key "follows", "users", column: "target_user_id", on_delete: :cascade
  add_foreign_key "follows", "users", on_delete: :cascade
  add_foreign_key "subscribes", "channels", on_delete: :cascade
  add_foreign_key "subscribes", "users", on_delete: :cascade
end
