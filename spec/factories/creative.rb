FactoryGirl.define do
  factory :creative, class: Creative do
    ad_id 1
    creative_name "creative_test"
    image "https://test.img"
    create_user_id 1
    update_user_id 1
  end
end
