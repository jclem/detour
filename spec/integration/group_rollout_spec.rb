require "spec_helper"

describe "group rollouts" do
  let(:user) { User.create(name: "foo") }
  let(:feature) { Detour::Feature.create(name: "foo") }
  let!(:flag) { feature.defined_group_flags.create(flaggable_type: "User", group_name: "foo_users") }

  describe "creating a group rollout" do
    before do
      Detour.config.define_user_group "foo_users" do |user|
        user.name == "foo"
      end
    end

    it "sets the feature on the user" do
      user.features.should include feature
    end
  end
end

