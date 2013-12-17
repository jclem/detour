require "spec_helper"

describe ActiveRecord::Rollout::GroupFlag do
  it { should be_a ActiveRecord::Rollout::Flag }
  it { should validate_presence_of :group_name }
  it { should allow_mass_assignment_of :group_name }
  it { should validate_uniqueness_of :feature_id }
end
