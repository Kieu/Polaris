FactoryGirl.define do
  factory :redirect_information, class: RedirectInformation do
    mpv "123456abcdef"
    client_id 1
    promotion_id 1
    media_category_id 1
    media_id 1
    account_id 1
    campaign_id 1
    group_id 1
    unit_id 1
    creative_id 1
    click_unit 1
    comment "xyz"
    del_flg "0"
    create_user_id 1
    update_user_id 1
  end
end
