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

  describe "#group_names" do
    before do
      Detour.config.define_user_group :admins do |user|
      end
    end

    it "returns the name of defined groups" do
      subject.group_names.should eq ["admins"]
    end
  end

  describe "#update_attributes" do
    let(:features_params) do
      {
        "foo_feature" => { users_percentage_flag_attributes: {} }
      }
    end

    it "updates the feature attributes" do
      Detour::Feature.any_instance.should_receive :assign_attributes
      Detour::Feature.any_instance.stub(:changed_for_autosave?) { true }
      Detour::Feature.any_instance.should_receive :save
      subject.update_attributes({ features: features_params })
    end

    context "when successful" do
      it "returns true" do
        subject.update_attributes({ features: features_params }).should be_true
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

    context "when a percentage flag should be removed" do
      let!(:percentage_flag) { create :percentage_flag, feature: feature }

      let(:features_params) do
        {
          "foo_feature" => { users_percentage_flag_attributes: { percentage: "" } },
        }
      end

      before do
        subject.update_attributes({ features: features_params });
      end

      it "destroys the percentage flag" do
        feature.reload.users_percentage_flag.should be_nil
      end
    end
  end
end
