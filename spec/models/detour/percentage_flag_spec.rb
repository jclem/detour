require "spec_helper"

describe Detour::PercentageFlag do
  subject { build :percentage_flag }

  it { should be_a Detour::Flag }
  it { should validate_numericality_of(:percentage).is_greater_than(0).is_less_than_or_equal_to(100) }
  it { should allow_mass_assignment_of :percentage }
  it { should validate_uniqueness_of :feature_id }
end
