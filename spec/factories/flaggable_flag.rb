FactoryGirl.define do
  factory :flaggable_flag, class: "Detour::FlaggableFlag" do
    feature
    association :flaggable, factory: :user
  end
end
