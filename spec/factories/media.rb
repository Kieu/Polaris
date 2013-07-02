FactoryGirl.define do
  factory :media, class: Media do
    media_name "media_test"
    media_category_id 1
    del_flg 0
  end
end
