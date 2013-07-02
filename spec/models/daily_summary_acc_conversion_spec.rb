require 'spec_helper'

describe DailySummaryAccConversion do
  let(:daily_summary_acc_conversion) {FactoryGirl.create(:daily_summary_acc_conversion)}

  subject {daily_summary_acc_conversion}

  it {should respond_to(:report_ymd)}
  it {should respond_to(:promotion_id)}
  it {should respond_to(:account_id)}
  it {should respond_to(:conversion_id)}
  it {should respond_to(:total_cv_count)}
  it {should respond_to(:first_cv_count)}
  it {should respond_to(:repeat_cv_count)}
  it {should respond_to(:conversion_rate)}
  it {should respond_to(:click_per_action)}
  it {should respond_to(:assist_count)}
  it {should respond_to(:sales)}
  it {should respond_to(:roas)}
  it {should respond_to(:roi)}
  it {should respond_to(:profit)}
  it {should be_valid}
end
