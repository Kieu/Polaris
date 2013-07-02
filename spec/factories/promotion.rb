FactoryGirl.define do
  factory :promotion, class: Promotion do
    promotion_name "promotion_test"
    roman_name "promotion_test"
    create_user_id 1
    promotion_category_id 1
    tracking_period 10
    client_id 1
    del_flg Settings.promotion.active
  end
end
