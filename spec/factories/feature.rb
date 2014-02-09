FactoryGirl.define do

  factory :feature, class: "Detour::Feature" do
    sequence(:name) { |n| "#{n}_feature" }
  end
end
