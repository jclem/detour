require "spec_helper"

describe "group rollouts" do
  let(:user) { User.create(name: "foo") }
  let(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }
  let!(:flag) { feature.flags.create(group_type: "User", group_name: "foo_users") }

  describe "creating a group rollout" do
    before do
      ActiveRecord::Rollout::Feature.define_user_group "foo_users" do |user|
        user.name == "foo"
      end
    end

    it "sets the feature on the user" do
      feature.match_groups?(user).should be_true
    end
  end
end

