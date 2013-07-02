FactoryGirl.define do
  factory :user_super, class: User do
    username "user_super"
    password "123456"
    email "user_super@example.com"
    create_user_id 1
    roman_name "user_super"
    company_id 1
    role_id Settings.role.SUPER
    password_flg "0"
    status Settings.user.active
  end

  factory :user_agency, class: User do
    username "user_agency"
    password "123456"
    email "user_agency@example.com"
    create_user_id 1
    roman_name "user_agency"
    company_id 1
    role_id Settings.role.AGENCY
    password_flg "0"
    status Settings.user.active
  end

  factory :user_client, class: User do
    username "user_client"
    password "123456"
    create_user_id 1
    email "user_client@example.com"
    roman_name "user_client"
    company_id 1
    role_id Settings.role.CLIENT
    password_flg "0"
    status Settings.user.active
  end
end
