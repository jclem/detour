require "spec_helper"

describe "flag rollouts" do
  let(:user) { User.create }

  describe "creating a flag rollout" do
    before do
      ActiveRecord::Rollout.create(name: "foo")
      ActiveRecord::Rollout.add_user(user, :foo)
    end

    it "sets the rollout on the user" do
      user.rollouts.collect(&:name).should include "foo"
    end
  end

  describe "removing a flag rollout" do
    before do
      ActiveRecord::Rollout.create(name: "foo")
      ActiveRecord::Rollout.add_user(user, :foo)
      ActiveRecord::Rollout.remove_user(user, :foo)
    end

    it "removes the rollout from the user" do
      user.rollouts.collect(&:name).should_not include "foo"
    end
  end
end
