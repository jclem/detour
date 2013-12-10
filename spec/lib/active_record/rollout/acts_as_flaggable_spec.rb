require "spec_helper"

describe ActiveRecord::Rollout::ActsAsFlaggable do
  subject { User.new }

  it { should have_many :flaggable_flags }
  it { should have_many :opt_out_flags }
  it { should have_many(:features).through(:flaggable_flags) }

  it "includes ActiveRecord::Rollout::Flaggable" do
    subject.class.ancestors.should include ActiveRecord::Rollout::Flaggable
  end
end
