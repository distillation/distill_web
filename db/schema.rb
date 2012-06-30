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

ActiveRecord::Schema.define(:version => 20120618211028) do

  create_table "programs", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "normal_file_name"
    t.text     "normal_file_contents"
    t.string   "arguments_file_name"
    t.text     "arguments_file_contents"
    t.integer  "number_of_levels"
    t.integer  "number_of_runs"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "programs", ["user_id"], :name => "index_programs_on_user_id"

  create_table "run_points", :force => true do |t|
    t.integer  "run_id"
    t.integer  "user_id"
    t.integer  "program_id"
    t.integer  "run_type_id"
    t.integer  "level_id"
    t.integer  "run_time"
    t.integer  "mem_size"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "run_points", ["program_id"], :name => "index_run_points_on_program_id"
  add_index "run_points", ["run_id"], :name => "index_run_points_on_run_id"
  add_index "run_points", ["run_type_id"], :name => "index_run_points_on_run_type_id"
  add_index "run_points", ["user_id"], :name => "index_run_points_on_user_id"

  create_table "run_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "runs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "program_id"
    t.decimal  "ghc_compile_time",        :precision => 10, :scale => 0
    t.decimal  "ghc_compile_time_o2",     :precision => 10, :scale => 0
    t.decimal  "super_compile_time",      :precision => 10, :scale => 0
    t.decimal  "super_compile_time_o2",   :precision => 10, :scale => 0
    t.decimal  "distill_compile_time",    :precision => 10, :scale => 0
    t.decimal  "distill_compile_time_o2", :precision => 10, :scale => 0
    t.integer  "ghc_size"
    t.integer  "ghc_size_o2"
    t.integer  "super_size"
    t.integer  "super_size_o2"
    t.integer  "distill_size"
    t.integer  "distill_size_o2"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  add_index "runs", ["program_id"], :name => "index_runs_on_program_id"
  add_index "runs", ["user_id"], :name => "index_runs_on_user_id"

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
