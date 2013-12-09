require "spec_helper"

describe ActiveRecord::Rollout::Flag do
  it { should belong_to :feature }
  it { should belong_to :flag_subject }
  it { should validate_presence_of :feature_id }
end
