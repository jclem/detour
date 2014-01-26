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

ActiveRecord::Schema.define(:version => 20131221052201) do

  create_table "detour_features", :force => true do |t|
    t.string   "name"
    t.integer  "failure_count",  :default => 0
    t.text     "flag_in_counts", :default => "{}"
    t.text     "opt_out_counts", :default => "{}"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "detour_features", ["name"], :name => "index_detour_features_on_name", :unique => true

  create_table "detour_flags", :force => true do |t|
    t.string   "type"
    t.integer  "feature_id"
    t.integer  "flaggable_id"
    t.string   "flaggable_type"
    t.string   "group_name"
    t.integer  "percentage"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "detour_flags", ["feature_id"], :name => "index_detour_flags_on_feature_id"
  add_index "detour_flags", ["type", "feature_id", "flaggable_type", "flaggable_id"], :name => "flag_type_feature_flaggable_type_id"
  add_index "detour_flags", ["type", "feature_id", "flaggable_type"], :name => "flag_type_feature_flaggable_type"
  add_index "detour_flags", ["type"], :name => "index_detour_flags_on_type"

  create_table "detour_groups", :force => true do |t|
    t.string   "name"
    t.string   "flaggable_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "detour_memberships", :force => true do |t|
    t.integer  "group_id"
    t.string   "member_type"
    t.integer  "member_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "detour_memberships", ["group_id", "member_type", "member_id"], :name => "detour_memberships_membership_index", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "widgets", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  add_index "widgets", ["user_id"], :name => "index_widgets_on_user_id"

end
