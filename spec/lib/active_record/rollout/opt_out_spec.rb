require "spec_helper"

describe ActiveRecord::Rollout::OptOut do
  it { should belong_to :rollout }
  it { should belong_to :opt_out_subject }
  it { should validate_presence_of :rollout_id }
end
