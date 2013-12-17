require "spec_helper"

describe "percentage rollouts" do
  let(:users) { 10.times.collect { User.create } }
  let(:feature) { Detour::Feature.create(name: "foo") }
  let!(:flag) { feature.percentage_flags.create(flaggable_type: "User", percentage: 20) }

  describe "creating a percentage rollout" do
    it "makes the feature available to the given percentage of instances" do
      users.select { |user| feature.match_percentage?(user) }.length.should eq users.length / 5
    end
  end
end
