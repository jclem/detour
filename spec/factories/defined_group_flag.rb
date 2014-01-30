FactoryGirl.define do
  factory :defined_group_flag, class: "Detour::DefinedGroupFlag" do
    feature
    flaggable_type "User"
    group_name "foo users"
  end
end
