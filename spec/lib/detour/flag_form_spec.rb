require "spec_helper"

describe Detour::FlagForm do
  subject { Detour::FlagForm.new("users") }

  let!(:feature) { create :feature, name: "foo_feature" }

  describe "#features" do
    before do
      Detour.config.grep_dirs = ["spec/dummy/app/**/*.{rb,erb}"]
    end

    it "returns every feature including lines" do
      subject.features.collect(&:name).should eq Detour::Feature.with_lines.collect(&:name)
    end
  end

  describe "#update_attributes" do
    it "updates the feature attributes" do
      Detour::Feature.any_instance.should_receive :update_attributes
      subject.update_attributes({ features: {} })
    end

    context "when successful" do
      it "returns true" do
        subject.update_attributes({ features: {} }).should be_true
      end
    end

    context "when unsuccessful" do
      it "returns nil" do
        subject.update_attributes({ features: { "foo_feature" => { users_percentage_flag_attributes: { percentage: "foo" } } } }).should be_nil
      end

      it "uses a transaction" do
        feature2 = create :feature, name: "foo_feature_2"

        subject.update_attributes({ features: {
          "foo_feature_2" => { users_percentage_flag_attributes: { percentage: 10 } },
          "foo_feature" => { users_percentage_flag_attributes: { percentage: "foo" } }
        } })

        feature2.users_percentage_flag.should be_nil
      end
    end
  end
end
