FactoryGirl.define do
  factory :opt_out_flag, class: "Detour::OptOutFlag" do
    feature
    association :flaggable, factory: :user
  end
end
