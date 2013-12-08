require "spec_helper"

describe "group rollouts" do
  let(:user) { User.create(name: "foo") }
  let(:rollout) { ActiveRecord::Rollout.create(name: "foo") }
  let!(:flag) { rollout.flags.create(group_type: "User", group_name: "foo_users") }

  describe "creating a group rollout" do
    before do
      ActiveRecord::Rollout.define_user_group "foo_users" do |user|
        user.name == "foo"
      end
    end

    it "sets the rollout on the user" do
      rollout.match_groups?(user).should be_true
    end
  end
end

