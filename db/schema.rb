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

ActiveRecord::Schema[8.1].define(version: 2026_10_16_161000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "attendances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "run_id", null: false
    t.uuid "runner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id", "runner_id"], name: "index_attendances_on_run_id_and_runner_id", unique: true
  end

  create_table "participant_ratings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "run_id", null: false
    t.uuid "rater_id", null: false
    t.uuid "ratee_id", null: false
    t.integer "punctuality", null: false
    t.integer "pace_accuracy", null: false
    t.integer "friendliness", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id", "rater_id", "ratee_id"], name: "unique_participant_rating", unique: true
    t.check_constraint "friendliness >= 1 AND friendliness <= 5", name: "valid_friendliness"
    t.check_constraint "pace_accuracy >= 1 AND pace_accuracy <= 5", name: "valid_pace_accuracy"
    t.check_constraint "punctuality >= 1 AND punctuality <= 5", name: "valid_punctuality"
  end

  create_table "running_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "run_id", null: false
    t.uuid "runner_id", null: false
    t.integer "distance_meters", null: false
    t.integer "duration_seconds", null: false
    t.datetime "occurred_at", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id", "runner_id"], name: "index_running_records_on_run_id_and_runner_id", unique: true
    t.index ["runner_id", "occurred_at"], name: "index_running_records_on_runner_id_and_occurred_at"
  end
end
