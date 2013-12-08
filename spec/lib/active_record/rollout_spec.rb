require "spec_helper"

describe ActiveRecord::Rollout do
  it { should be_a ActiveRecord::Base }
  it { should have_many(:flags).dependent(:destroy) }
  it { should validate_presence_of :name }
end
