require "spec_helper"

describe Detour::FlaggableFlag do
  it { should be_a Detour::Flag }
  it { should belong_to :flaggable }
  it { should validate_presence_of :flaggable_id }
  it { should allow_mass_assignment_of :flaggable }
  it { should validate_uniqueness_of :feature_id }
end
