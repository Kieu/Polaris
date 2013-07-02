FactoryGirl.define do
  factory :account, class: Account do
    promotion_id 1
    media_id 1
    sync_account_id "1234567"
    sync_account_pw "123456789"
    account_name "account_name"
    roman_name "roman_name"
    sync_flg 1
    margin 100
    create_user_id 1
    update_user_id 1
  end
end
