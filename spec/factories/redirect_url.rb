FactoryGirl.define do
  factory :redirect_url, class: RedirectUrl do
    mpv "123456abcdef"
    url "https://www.test.com"
    rate 10
    name "test_url"
    create_user_id 1
    update_user_id 1
  end
end
