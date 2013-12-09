require "spec_helper"

describe "flag rollouts" do
  let(:user) { User.create }
  let(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  describe "creating a flag rollout" do
    before do
      ActiveRecord::Rollout::Feature.add_record_to_feature user, feature.name
    end

    it "sets the feature on the user" do
      feature.match_id?(user).should be_true
    end
  end

  describe "removing a flag rollout" do
    before do
      ActiveRecord::Rollout::Feature.add_record_to_feature user, feature.name
      ActiveRecord::Rollout::Feature.remove_record_from_feature user, feature.name
    end

    it "removes the feature from the user" do
      feature.match_id?(user).should be_false
    end
  end
end
