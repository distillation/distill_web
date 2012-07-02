# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120618210902) do

  create_table "programs", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "normal_file_name"
    t.text     "normal_file_contents"
    t.string   "arguments_file_name"
    t.text     "arguments_file_contents"
    t.integer  "number_of_levels"
    t.integer  "number_of_runs"
    t.text     "super_file_contents"
    t.text     "distill_file_contents"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "programs", ["user_id"], :name => "index_programs_on_user_id"

  create_table "run_points", :force => true do |t|
    t.integer  "program_id"
    t.integer  "run_type_id"
    t.integer  "level_number"
    t.decimal  "run_time",     :precision => 10, :scale => 0
    t.integer  "mem_size"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "run_points", ["program_id"], :name => "index_run_points_on_program_id"
  add_index "run_points", ["run_type_id"], :name => "index_run_points_on_run_type_id"

  create_table "run_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "folder_name"
    t.string   "options"
    t.string   "transformation_name"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "user_sessions", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

end
