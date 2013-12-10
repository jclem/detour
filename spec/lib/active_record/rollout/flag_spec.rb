require "spec_helper"

describe ActiveRecord::Rollout::Flag do
  it { should belong_to :feature }
  it { should validate_presence_of :feature_id }
  it { should validate_presence_of :flaggable_type }
end
