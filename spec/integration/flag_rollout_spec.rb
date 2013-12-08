require "spec_helper"

describe "flag rollouts" do
  let(:user) { User.create }

  describe "creating a rollout" do
    before do
      ActiveRecord::Rollout.create(name: "foo")
      ActiveRecord::Rollout.add_user(user, :foo)
    end

    it "sets the rollout on the user" do
      user.rollouts.collect(&:name).should include "foo"
    end
  end
end
