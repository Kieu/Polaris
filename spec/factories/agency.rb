FactoryGirl.define do
  factory :agency, class: Agency do
    agency_name "agency_test"
    roman_name "agency_test"
    create_user_id 1
  end
end
