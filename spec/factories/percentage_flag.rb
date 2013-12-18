FactoryGirl.define do
  factory :percentage_flag, class: "Detour::PercentageFlag" do
    feature
    flaggable_type "User"
    percentage 50
  end
end
