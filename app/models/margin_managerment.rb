class MarginManagerment < ActiveRecord::Base
  attr_accessible :account_id, :create_time, :create_user_id, :integer, :margin_rate, :report_ymd, :update_user_id, :update_user_id
end
