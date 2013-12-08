require "spec_helper"

describe "flag rollouts" do
  let(:user) { User.create }
  let(:rollout) { ActiveRecord::Rollout.create(name: "foo") }

  describe "creating a flag rollout" do
    before do
      ActiveRecord::Rollout.add_user(user, rollout.name)
    end

    it "sets the rollout on the user" do
      rollout.match_user?(user).should be_true
    end
  end

  describe "removing a flag rollout" do
    before do
      ActiveRecord::Rollout.add_user(user, rollout.name)
      ActiveRecord::Rollout.remove_user(user, rollout.name)
    end

    it "removes the rollout from the user" do
      rollout.match_user?(user).should be_false
    end
  end
end
