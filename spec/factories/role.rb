FactoryGirl.define do
  factory :role_super, class: Role do
    id "1"
    role_name "Super"
  end
  
  factory :role_client, class: Role do
    id "2"
    role_name "Client"
  end
  
  factory :role_agency, class: Role do
    id "3"
    role_name "Agency"
  end
end
