FactoryGirl.define do
  factory :client, class: Client do
    client_name "client_test"
    roman_name "client_test"
    create_user_id 1
    tel "123456"
    contract_flg 0
    contract_type 0
    person_charge "person_charge"
    person_sale "person_sale"
  end
end
