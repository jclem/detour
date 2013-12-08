require "spec_helper"

describe "percentage rollouts" do
  let(:users) { 10.times.collect { User.create } }
  let(:rollout) { ActiveRecord::Rollout.create(name: "foo") }
  let!(:flag) { rollout.flags.create(percentage_type: "User", percentage: 20) }

  describe "creating a percentage rollout" do
    it "makes the rollout available to the given percentage of instances" do
      users.select { |user| rollout.match_percentage?(user) }.length.should eq users.length / 5
    end
  end
end
