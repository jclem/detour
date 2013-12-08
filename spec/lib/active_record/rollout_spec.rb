require "spec_helper"

describe ActiveRecord::Rollout do
  it { should be_a ActiveRecord::Base }
  it { should have_many(:flags).dependent(:destroy) }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  describe ".add_{klass}" do
    let(:user) { User.create }

    it "creates a flag from the given instance" do
      ActiveRecord::Rollout.should_receive(:create_flag_from_instance).with user, :foo
      ActiveRecord::Rollout.add_user user, :foo
    end
  end

  describe ".create_flag_from_instance" do
    let(:user) { User.create }
    let!(:rollout) { ActiveRecord::Rollout.create!(name: "foo") }

    before do
      ActiveRecord::Rollout.create_flag_from_instance user, :foo
    end

    it "creats a flag for the given instance and rollout" do
      user.rollouts.should include rollout
    end
  end
end
