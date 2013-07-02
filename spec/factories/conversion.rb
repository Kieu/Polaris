FactoryGirl.define do
  factory :cv_web, class: Conversion do
    promotion_id 1
    conversion_name "web"
    roman_name "web"
    conversion_category "1"
    duplicate "1"
    unique_def "1"
    start_point "1"
    sale_unit_price 100
    reward_form "1"
  end

  factory :cv_app_action, class: Conversion do
    promotion_id 1
    conversion_name "app_action"
    roman_name "app_action"
    conversion_category "2"
    track_type "2"
    session_period 90
    unique_def "1"
    sale_unit_price 100
    reward_form "1"
  end

  factory :cv_app_install, class: Conversion do
    promotion_id 1
    conversion_name "app_install"
    roman_name "app_install"
    conversion_category "2"
    track_type "1"
    os "1"
    conversion_mode "0"
    duplicate "1"
    track_method "4"
    url "https://www.testing.com"
    facebook_app_id 123456789
    unique_def "1"
    judging "1"
    sale_unit_price 100
    reward_form "1"
  end
end
