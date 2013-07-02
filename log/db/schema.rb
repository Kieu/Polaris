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

ActiveRecord::Schema.define(:version => 20130617091743) do

  create_table "accounts", :force => true do |t|
    t.integer  "promotion_id"
    t.integer  "media_id"
    t.string   "sync_account_id"
    t.string   "sync_account_pw"
    t.string   "account_name"
    t.string   "roman_name"
    t.integer  "sync_flg"
    t.float    "cost"
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "created_at"
    t.datetime "updated_date"
    t.integer  "del_flg",           :default => 0
    t.integer  "media_category_id"
  end

  create_table "agencies", :force => true do |t|
    t.string   "agency_name"
    t.string   "roman_name"
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "agencies", ["agency_name"], :name => "index_agencies_on_agency_name", :unique => true
  add_index "agencies", ["roman_name"], :name => "index_agencies_on_roman_name", :unique => true

  create_table "background_jobs", :force => true do |t|
    t.integer  "user_id"
    t.string   "filename",   :limit => 512
    t.string   "type_view"
    t.string   "status",     :limit => 1
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "job_id"
    t.string   "filepath"
  end

  create_table "block_login_users", :force => true do |t|
    t.integer  "user_id"
    t.datetime "block_at_time"
    t.integer  "login_fail_num", :limit => 1
  end

  create_table "click_1_logs", :force => true do |t|
    t.integer  "media_category_id"
    t.integer  "media_id"
    t.integer  "account_id"
    t.integer  "campaign_id"
    t.integer  "ad_group_id"
    t.integer  "ad_id"
    t.integer  "redirect_infomation_id"
    t.string   "mpv"
    t.text     "click_url"
    t.integer  "redirect_url_id"
    t.integer  "creative_id"
    t.string   "session_id"
    t.string   "verify"
    t.text     "request_uri"
    t.text     "redirect_url"
    t.string   "media_session_id"
    t.string   "device_category"
    t.text     "user_agent"
    t.text     "referrer"
    t.integer  "click_time"
    t.integer  "click_ymd"
    t.string   "remote_ip"
    t.string   "mark"
    t.string   "access_track_server"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "click_error_1_logs", :force => true do |t|
    t.integer  "media_category_id"
    t.integer  "media_id"
    t.integer  "account_id"
    t.integer  "campaign_id"
    t.integer  "ad_group_id"
    t.integer  "ad_id"
    t.integer  "redirect_infomation_id"
    t.string   "mpv"
    t.text     "click_url"
    t.integer  "redirect_url_id"
    t.integer  "creative_id"
    t.string   "session_id"
    t.string   "verify"
    t.text     "request_uri"
    t.text     "redirect_url"
    t.string   "media_session_id"
    t.string   "device_category"
    t.text     "user_agent"
    t.text     "referrer"
    t.integer  "click_time"
    t.integer  "click_ymd"
    t.string   "remote_ip"
    t.string   "mark"
    t.string   "access_track_server"
    t.string   "error_code"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "client_users", :force => true do |t|
    t.integer  "client_id"
    t.integer  "user_id"
    t.integer  "del_flg",    :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "client_users", ["client_id", "user_id"], :name => "index_client_users_on_client_id_and_user_id", :unique => true

  create_table "clients", :force => true do |t|
    t.string   "client_name"
    t.string   "roman_name"
    t.string   "tel"
    t.string   "department_name"
    t.integer  "contract_flg"
    t.integer  "contract_type"
    t.integer  "del_flg",         :default => 0
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.string   "person_charge"
    t.string   "person_sale"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "clients", ["client_name"], :name => "index_clients_on_client_name", :unique => true
  add_index "clients", ["roman_name"], :name => "index_clients_on_roman_name", :unique => true

  create_table "conversion_1_logs", :force => true do |t|
    t.integer  "media_category_id"
    t.integer  "media_id"
    t.integer  "account_id"
    t.integer  "campaign_id"
    t.integer  "ad_group_id"
    t.integer  "ad_id"
    t.integer  "conversion_id"
    t.integer  "redirect_infomation_id"
    t.string   "mpv"
    t.integer  "redirect_url_id"
    t.integer  "creative_id"
    t.string   "session_id"
    t.string   "verify"
    t.string   "suid"
    t.text     "request_uri"
    t.text     "request_url"
    t.text     "redirect_url"
    t.string   "media_session_id"
    t.string   "device_category"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "click_referrer"
    t.string   "repeat_proccessed_flg"
    t.string   "parent_conversion_id"
    t.integer  "access_time"
    t.integer  "access_vmd"
    t.integer  "click_time"
    t.string   "remote_ip"
    t.string   "mark"
    t.string   "conversion_category"
    t.string   "conversion_type"
    t.string   "repeat_flg"
    t.integer  "profit"
    t.integer  "volume"
    t.string   "approval_status"
    t.text     "send_url"
    t.integer  "send_utime"
    t.string   "access_track_server"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "conversion_error_1_logs", :force => true do |t|
    t.integer  "media_category_id"
    t.integer  "media_id"
    t.integer  "account_id"
    t.integer  "campaign_id"
    t.integer  "ad_group_id"
    t.integer  "ad_id"
    t.integer  "conversion_id"
    t.integer  "redirect_infomation_id"
    t.string   "mpv"
    t.integer  "redirect_url_id"
    t.integer  "creative_id"
    t.string   "session_id"
    t.string   "verify"
    t.string   "suid"
    t.text     "reqest_url"
    t.text     "redirect_url"
    t.string   "media_session_id"
    t.string   "device_category"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "click_referrer"
    t.integer  "access_time"
    t.integer  "access_vmd"
    t.integer  "click_time"
    t.string   "remote_ip"
    t.string   "mark"
    t.string   "conversion_category"
    t.string   "conversion_type"
    t.integer  "sales"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "conversion_organic_1_logs", :force => true do |t|
    t.integer  "conversion_id"
    t.integer  "redirect_infomation_id"
    t.string   "verify"
    t.string   "suid"
    t.text     "reqest_url"
    t.text     "redirect_url"
    t.string   "media_session_id"
    t.string   "device_category"
    t.text     "user_agent"
    t.text     "referrer"
    t.integer  "access_time"
    t.integer  "access_vmd"
    t.string   "remote_ip"
    t.string   "conversion_category"
    t.string   "conversion_type"
    t.string   "repeat_flg"
    t.string   "repeat_proccessed_flg"
    t.integer  "parent_conversion_id"
    t.integer  "sales"
    t.integer  "profit"
    t.integer  "volume"
    t.text     "others"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "conversions", :force => true do |t|
    t.integer  "promotion_id"
    t.string   "conversion_name"
    t.string   "roman_name"
    t.integer  "sale_unit_price"
    t.integer  "facebook_app_id"
    t.text     "url"
    t.integer  "session_period"
    t.text     "conversion_combine"
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "mv"
    t.string   "conversion_category", :limit => 1
    t.string   "duplicate",           :limit => 1
    t.string   "unique_def",          :limit => 2
    t.string   "start_point",         :limit => 1
    t.string   "reward_form",         :limit => 1
    t.string   "os",                  :limit => 1
    t.string   "conversion_mode",     :limit => 1
    t.string   "judging",             :limit => 1
    t.string   "track_type",          :limit => 1
    t.string   "track_method",        :limit => 1
  end

  add_index "conversions", ["promotion_id", "conversion_name"], :name => "index_conversions_on_promotion_id_and_conversion_name", :unique => true
  add_index "conversions", ["promotion_id", "roman_name"], :name => "index_conversions_on_promotion_id_and_roman_name", :unique => true

  create_table "creatives", :force => true do |t|
    t.integer  "ad_id"
    t.string   "creative_name",  :limit => 256
    t.string   "image",          :limit => 512
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "create_time"
    t.datetime "update_time"
    t.string   "del_flg",        :limit => 1
    t.text     "text"
    t.string   "type",           :limit => 1
  end

  create_table "daily_summary_acc_conversions", :force => true do |t|
    t.integer  "report_ymd"
    t.integer  "promotion_id"
    t.integer  "account_id"
    t.integer  "conversion_id"
    t.integer  "total_cv_count"
    t.integer  "first_cv_count"
    t.integer  "repeat_cv_count"
    t.float    "conversion_rate"
    t.integer  "click_per_action"
    t.integer  "assist_count"
    t.integer  "sales"
    t.float    "roas"
    t.integer  "profit",           :limit => 8
    t.float    "roi"
    t.datetime "create_time"
    t.datetime "update_time"
  end

  create_table "daily_summary_accounts", :force => true do |t|
    t.integer  "media_category_id"
    t.integer  "media_id"
    t.integer  "account_id"
    t.integer  "promotion_id"
    t.integer  "imp_count",           :limit => 8
    t.integer  "click_count",         :limit => 8
    t.float    "click_through_ratio"
    t.integer  "cost_sum",            :limit => 8
    t.float    "cost_per_click"
    t.float    "cost_per_mille"
    t.integer  "report_ymd"
    t.datetime "create_time"
    t.datetime "update_time"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "display_ads", :force => true do |t|
    t.string   "identifier"
    t.string   "name"
    t.integer  "client_id"
    t.integer  "promotion_id"
    t.integer  "account_id"
    t.integer  "display_campaign_id", :limit => 8
    t.integer  "display_group_id",    :limit => 8
    t.string   "del_flg",             :limit => 1, :default => "0", :null => false
    t.integer  "create_usr_id"
    t.integer  "update_usr_id"
    t.datetime "create_at"
    t.datetime "update_at"
  end

  add_index "display_ads", ["name"], :name => "index1"

  create_table "display_campaigns", :force => true do |t|
    t.string   "name"
    t.integer  "client_id"
    t.integer  "promotion_id"
    t.integer  "account_id"
    t.string   "del_flg",       :limit => 1, :default => "0", :null => false
    t.integer  "create_usr_id"
    t.integer  "update_usr_id"
    t.datetime "create_at"
    t.datetime "update_at"
  end

  create_table "display_groups", :force => true do |t|
    t.string   "name"
    t.integer  "client_id"
    t.integer  "promotion_id"
    t.integer  "account_id"
    t.integer  "display_campaign_id", :limit => 8
    t.string   "del_flg",             :limit => 1, :default => "0", :null => false
    t.integer  "create_usr_id"
    t.integer  "update_usr_id"
    t.datetime "create_at"
    t.datetime "update_at"
  end

  add_index "display_groups", ["display_campaign_id"], :name => "fk_display_groups_1"
  add_index "display_groups", ["name"], :name => "index1"

  create_table "ext_action_point_reports", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ext_promotion_reports", :force => true do |t|
    t.integer  "promotion_id"
    t.integer  "media_category_id"
    t.integer  "media_id"
    t.integer  "account_id"
    t.integer  "imp"
    t.integer  "click"
    t.integer  "cost"
    t.date     "report_date"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "imports", :force => true do |t|
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.string   "csv_file_size"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "margin_managements", :force => true do |t|
    t.integer  "report_ymd"
    t.integer  "margin_rate"
    t.datetime "create_time"
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "update_time"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "account_id"
  end

  create_table "media", :force => true do |t|
    t.integer "media_category_id"
    t.string  "media_name"
    t.integer "del_flg",           :limit => 1, :default => 0
  end

  create_table "press_releases", :force => true do |t|
    t.text     "content"
    t.datetime "release_time"
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "promotions", :force => true do |t|
    t.string   "promotion_name"
    t.integer  "promotion_category_id"
    t.integer  "client_id"
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.integer  "del_flg",               :default => 0
    t.integer  "agency_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "roman_name"
    t.integer  "tracking_period"
  end

  add_index "promotions", ["promotion_name", "client_id"], :name => "index_promotions_on_promotion_name_and_client_id", :unique => true
  add_index "promotions", ["roman_name", "client_id"], :name => "index_promotions_on_roman_name_and_client_id", :unique => true

  create_table "redirect_infomations", :force => true do |t|
    t.string   "mpv"
    t.integer  "client_id"
    t.integer  "promotion_id"
    t.integer  "media_category_id"
    t.integer  "media_id"
    t.integer  "account_id"
    t.integer  "campaign_id"
    t.integer  "group_id"
    t.integer  "unit_id"
    t.integer  "creative_id"
    t.integer  "click_unit"
    t.text     "comment"
    t.string   "del_flg",           :limit => 1
    t.datetime "create_at"
    t.integer  "create_usr_id"
    t.datetime "update_at"
    t.integer  "update_usr_id"
    t.integer  "create_user_id"
    t.integer  "update_user_id"
  end

  create_table "redirect_urls", :force => true do |t|
    t.string   "mpv"
    t.text     "url"
    t.integer  "rate"
    t.string   "name"
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "update_time"
    t.datetime "create_at"
    t.datetime "update_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "role_name"
    t.integer  "status",         :default => 0
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "roman_name"
    t.string   "password_digest"
    t.string   "email"
    t.integer  "role_id"
    t.integer  "password_flg"
    t.string   "language"
    t.datetime "last_login"
    t.integer  "status",          :default => 0
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "company_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["roman_name"], :name => "index_users_on_roman_name", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "users1", :force => true do |t|
    t.string   "username"
    t.string   "roman_name"
    t.string   "password_digest"
    t.string   "email"
    t.integer  "role_id"
    t.integer  "password_flg"
    t.string   "language"
    t.datetime "last_login"
    t.integer  "status",          :default => 0
    t.integer  "create_user_id"
    t.integer  "update_user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "company_id"
  end

  add_index "users1", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users1", ["roman_name"], :name => "index_users_on_roman_name", :unique => true
  add_index "users1", ["username"], :name => "index_users_on_username", :unique => true

end
