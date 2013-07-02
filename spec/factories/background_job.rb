FactoryGirl.define do
  factory :background_job, class: BackgroundJob do
    user_id "1"
    filename "test.txt"
    type_view "download"
    status "1"
    filepath "test"
    job_id "1"
  end
end