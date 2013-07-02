class DailySummaryAccConversion < ActiveRecord::Base
  establish_connection "log_db_#{Rails.env}"
  attr_accessible :report_ymd, :account_id, :assist_count, :click_per_action,
    :conversion_id, :conversion_rate, :create_time, :first_cv_count, :id,
    :profit, :promotion_id, :repeat_cv_count, :roas, :roi, :sales,
    :total_cv_count, :update_time

  belongs_to :account
  belongs_to :conversion
end