require "spec_helper"

describe ActiveRecord::Rollout::PercentageFlag do
  subject { ActiveRecord::Rollout::PercentageFlag.new(feature_id: 1, flaggable_type: "User") }

  it { should be_a ActiveRecord::Rollout::Flag }
  it { should validate_numericality_of(:percentage).is_greater_than(0).is_less_than_or_equal_to(100) }
end
