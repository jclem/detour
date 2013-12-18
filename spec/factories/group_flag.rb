FactoryGirl.define do
  factory :group_flag, class: "Detour::GroupFlag" do
    feature
    flaggable_type "User"
    group_name "foo users"
  end
end
