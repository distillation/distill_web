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

ActiveRecord::Schema.define(:version => 20120530151114) do

  create_table "programs", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "file_name"
    t.integer  "size"
    t.integer  "lines"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "timings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "program_id"
    t.string   "arguments"
    t.decimal  "normal_compile"
    t.decimal  "normal_O2_compile"
    t.decimal  "super_compile"
    t.decimal  "super_O2_compile"
    t.decimal  "distill_compile"
    t.decimal  "distill_O2_compile"
    t.decimal  "normal_time"
    t.decimal  "normal_O2_time"
    t.decimal  "super_time"
    t.decimal  "super_O2_time"
    t.decimal  "distill_time"
    t.decimal  "distill_02_time"
    t.integer  "normal_mem"
    t.integer  "normal_O2_mem"
    t.integer  "super_mem"
    t.integer  "super_O2_mem"
    t.integer  "distill_mem"
    t.integer  "distill_O2_mem"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
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
