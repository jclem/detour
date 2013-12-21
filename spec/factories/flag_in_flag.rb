FactoryGirl.define do
  factory :flag_in_flag, class: "Detour::FlagInFlag" do
    feature
    association :flaggable, factory: :user
  end
end
