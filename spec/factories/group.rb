FactoryGirl.define do
  sequence :name do |n|
    "Group #{n}"
  end

  factory :group, class: "Detour::Group" do
    flaggable_type "User"
    name
  end
end
