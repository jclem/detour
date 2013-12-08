require "spec_helper"

describe "percentage rollouts" do
  let(:user) { User.create }
  let(:user2) { User.create }
  let(:user3) { User.create }
  let(:user4) { User.create }
  let(:users) { [user, user2, user3, user4] }
  let(:rollout) { ActiveRecord::Rollout.create(name: "foo", percentage: 50) }

  describe "creating a percentage rollout" do
    it "makes the rollout available to the given percentage of instances" do
      users.select { |user| rollout.match_percentage?(user) }.length.should eq users.length / 2
    end
  end
end
