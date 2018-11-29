# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180517093429) do

  create_table "analyses", force: :cascade do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.string   "thumbnail_url"
    t.integer  "creator_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "analyses_assignments", id: false, force: :cascade do |t|
    t.integer "assignment_id", null: false
    t.integer "analysis_id",   null: false
  end

  create_table "analyses_attachments", id: false, force: :cascade do |t|
    t.integer "attachment_id", null: false
    t.integer "analysis_id",   null: false
  end

  create_table "analyses_examples", force: :cascade do |t|
    t.integer "analysis_id"
    t.integer "example_id"
  end

  create_table "analyses_software", force: :cascade do |t|
    t.integer "analysis_id"
    t.integer "software_id"
  end

  create_table "analyses_tags", force: :cascade do |t|
    t.integer "analysis_id"
    t.integer "tag_id"
  end

  create_table "analyses_web_resources", force: :cascade do |t|
    t.integer "analysis_id"
    t.integer "web_resource_id"
  end

  create_table "assignment_results", force: :cascade do |t|
    t.string   "instructor"
    t.string   "course_prefix"
    t.string   "course_number"
    t.string   "course_title"
    t.string   "field_of_study"
    t.string   "semester"
    t.float    "project_length_weeks"
    t.integer  "students_given_assignment"
    t.float    "instruction_hours"
    t.float    "average_student_score"
    t.text     "outcome_summary"
    t.integer  "assignment_id"
    t.integer  "creator_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "assignment_results_attachments", id: false, force: :cascade do |t|
    t.integer "attachment_id",        null: false
    t.integer "assignment_result_id", null: false
  end

  create_table "assignments", force: :cascade do |t|
    t.string   "author"
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.string   "thumbnail_url"
    t.string   "learning_curve"
    t.float    "instruction_hours"
    t.integer  "creator_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "assignments_assignments", force: :cascade do |t|
    t.integer "from_assignment_id"
    t.integer "to_assignment_id"
  end

  create_table "assignments_attachments", id: false, force: :cascade do |t|
    t.integer "attachment_id", null: false
    t.integer "assignment_id", null: false
  end

  create_table "assignments_datasets", id: false, force: :cascade do |t|
    t.integer "assignment_id", null: false
    t.integer "dataset_id",    null: false
  end

  create_table "assignments_examples", force: :cascade do |t|
    t.integer "assignment_id"
    t.integer "example_id"
  end

  create_table "assignments_software", id: false, force: :cascade do |t|
    t.integer "assignment_id", null: false
    t.integer "software_id",   null: false
  end

  create_table "assignments_tags", force: :cascade do |t|
    t.integer "assignment_id"
    t.integer "tag_id"
  end

  create_table "assignments_web_resources", force: :cascade do |t|
    t.integer "assignment_id"
    t.integer "web_resource_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "file_attachment_file_name"
    t.string   "file_attachment_content_type"
    t.integer  "file_attachment_file_size"
    t.datetime "file_attachment_updated_at"
    t.string   "file_attachment_fingerprint"
    t.integer  "uploaded_by_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "description",                  default: ""
    t.integer  "display_position",             default: 0
  end

  create_table "attachments_datasets", id: false, force: :cascade do |t|
    t.integer "attachment_id", null: false
    t.integer "dataset_id",    null: false
  end

  create_table "attachments_examples", id: false, force: :cascade do |t|
    t.integer "attachment_id", null: false
    t.integer "example_id",    null: false
  end

  create_table "attachments_software", id: false, force: :cascade do |t|
    t.integer "attachment_id", null: false
    t.integer "software_id",   null: false
  end

  create_table "bootsy_image_galleries", force: :cascade do |t|
    t.string   "bootsy_resource_type"
    t.integer  "bootsy_resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: :cascade do |t|
    t.string   "image_file"
    t.integer  "image_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "datasets", force: :cascade do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.string   "thumbnail_url"
    t.integer  "creator_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "datasets_examples", force: :cascade do |t|
    t.integer "dataset_id"
    t.integer "example_id"
  end

  create_table "datasets_tags", force: :cascade do |t|
    t.integer "dataset_id"
    t.integer "tag_id"
  end

  create_table "datasets_web_resources", force: :cascade do |t|
    t.integer "dataset_id"
    t.integer "web_resource_id"
  end

  create_table "examples", force: :cascade do |t|
    t.integer  "dataset_id"
    t.integer  "software_id"
    t.integer  "analysis_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "creator_id"
    t.string   "summary"
  end

  create_table "examples_software", force: :cascade do |t|
    t.integer "software_id"
    t.integer "example_id"
  end

  create_table "examples_tags", force: :cascade do |t|
    t.integer "example_id"
    t.integer "tag_id"
  end

  create_table "examples_web_resources", force: :cascade do |t|
    t.integer "example_id"
    t.integer "web_resource_id"
  end

  create_table "permission_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "level_requested"
    t.boolean  "reviewed",        default: false
    t.boolean  "granted",         default: false
    t.integer  "reviewed_by_id"
    t.datetime "reviewed_on"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "software", force: :cascade do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.string   "thumbnail_url"
    t.integer  "creator_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "software_tags", force: :cascade do |t|
    t.integer "software_id"
    t.integer "tag_id"
  end

  create_table "software_web_resources", force: :cascade do |t|
    t.integer "software_id"
    t.integer "web_resource_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "role"
    t.string   "field_of_study"
    t.string   "password_digest"
    t.string   "activation_digest"
    t.boolean  "activated"
    t.datetime "activated_at"
    t.string   "remember_digest"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "permission_level",               default: "viewer"
    t.datetime "permission_level_granted_on"
    t.integer  "permission_level_granted_by_id"
    t.boolean  "deleted"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "web_resources", force: :cascade do |t|
    t.string   "url"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end