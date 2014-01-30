FactoryGirl.define do
  factory :database_group_flag, class: "Detour::DatabaseGroupFlag" do
    feature
    flaggable_type "User"
    group
  end
end
