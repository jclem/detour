require "spec_helper"

describe Detour::GroupFlag do
  it { should be_a Detour::Flag }
  it { should validate_presence_of :group_name }
  it { should allow_mass_assignment_of :group_name }
  it { should validate_uniqueness_of :feature_id }
end
