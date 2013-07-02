FactoryGirl.define do
  factory :daily_summary_acc_conversion, class: DailySummaryAccConversion do
    report_ymd 20130101
    promotion_id 1
    account_id 1
    conversion_id 1
    total_cv_count 10
    first_cv_count 1
    repeat_cv_count 10
    conversion_rate 1.0
    click_per_action 10
    assist_count 10
    sales 10
    roas 1.0
    profit 10
    roi 1.5
  end
end
