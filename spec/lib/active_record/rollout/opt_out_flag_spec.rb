require "spec_helper"

describe ActiveRecord::Rollout::OptOutFlag do
  it { should be_a ActiveRecord::Rollout::Flag }
  it { should belong_to :flaggable }
  it { should validate_presence_of :flaggable_id }
  it { should allow_mass_assignment_of :flaggable}
end
