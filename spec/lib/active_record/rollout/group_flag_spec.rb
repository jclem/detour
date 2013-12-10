require "spec_helper"

describe ActiveRecord::Rollout::GroupFlag do
  it { should be_a ActiveRecord::Rollout::Flag }
  it { should validate_presence_of :group_name }
end
