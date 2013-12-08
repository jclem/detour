require "spec_helper"

describe ActiveRecord::Rollout::Flag do
  it { should be_a ActiveRecord::Base }
  it { should belong_to :rollout }
  it { should validate_presence_of :rollout_id }
end
