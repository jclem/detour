FactoryGirl.define do
  factory :membership, class: "Detour::Membership" do
    association :member, factory: :user
    group
  end
end
