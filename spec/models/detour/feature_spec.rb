require "spec_helper"
require "fakefs/spec_helpers"

describe Detour::Feature do
  it { should have_many(:flag_in_flags) }
  it { should have_many(:database_group_flags) }
  it { should have_many(:defined_group_flags) }
  it { should have_many(:percentage_flags) }
  it { should have_many(:opt_out_flags) }
  it { should have_many(:flags).dependent(:destroy) }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should allow_mass_assignment_of :name }

  it { should allow_value("foo").for(:name) }
  it { should allow_value("foo_bar").for(:name) }
  it { should allow_value("foo-bar").for(:name) }
  it { should_not allow_value("foo-bar.").for(:name) }

  describe "name format validation" do
    let(:feature) { build :feature, name: "foo bar." }

    it "returns a readable format error" do
      feature.valid?
      feature.errors[:name].should eq ["must be composed of letters, numbers, underscores, and dashes"]
    end
  end

  describe ".with_lines" do
    include FakeFS::SpecHelpers

    let(:feature) { create :feature, name: "foo" }

    before do
      Detour.config.grep_dirs = ["/foo/**/*.rb"]

      FileUtils.mkdir("/foo")

      File.open("/foo/bar.rb", "w") do |file|
        file.write <<-EOF
          current_user.has_feature?(:foo) do
          end

          current_user.has_feature?(:bar) do
          end

          current_user.has_feature?(:foo) do
          end

          current_user.rollout?(:foo) do
          end
        EOF
      end

      File.open("/foo/baz.rb", "w") do |file|
        file.write <<-EOF
          current_user.has_feature?(:foo) || current_user.has_feature?(:bar)

          current_user.has_feature? :bar do
          end
        EOF
      end
    end

    context "when there is a custom feature search regex" do
      before do
        Detour.config.feature_search_regex = /rollout\?\(:(\w+)\)/
      end

      after do
        Detour.config.instance_variable_set "@feature_search_regex", nil
      end

      it "uses the custom feature search regex" do
        persisted_feature = Detour::Feature.with_lines.detect { |f| f.name == feature.name }
        persisted_feature.lines.should eq %w[/foo/bar.rb#L10]
      end
    end

    it "fetches lines for persisted features" do
      persisted_feature = Detour::Feature.with_lines.detect { |f| f.name == feature.name }
      persisted_feature.lines.should eq %w[/foo/bar.rb#L1 /foo/bar.rb#L7 /foo/baz.rb#L1]
    end

    it "fetches lines for un-persisted features" do
      unpersisted_feature = Detour::Feature.with_lines.detect { |f| f.name == "bar" }
      unpersisted_feature.lines.should eq %w[/foo/bar.rb#L4 /foo/baz.rb#L1 /foo/baz.rb#L3]
    end
  end

  describe "#to_s" do
    let(:feature) { create :feature }

    it "returns the name of the feature" do
      feature.to_s.should eq feature.name
    end
  end

  describe "#match?" do
    let(:user)    { create :user }
    let(:feature) { create :feature }

    it "checks if the user is flagged individually" do
      feature.should_receive(:match_id?).with(user)
      feature.match?(user)
    end

    it "checks if the user is flagged as part of a percentage" do
      feature.should_receive(:match_percentage?).with(user)
      feature.match?(user)
    end

    it "checks if the user is flagged as part of a database group" do
      feature.should_receive(:match_database_groups?).with(user)
      feature.match?(user)
    end

    it "checks if the user is flagged as part of a defined group" do
      feature.should_receive(:match_defined_groups?).with(user)
      feature.match?(user)
    end
  end

  describe "#flag_in_count_for" do
    context "when a value does not exist" do
      let(:feature) { create :feature }

      it "returns 0" do
        feature.flag_in_count_for("users").should eq 0
      end
    end

    context "when a value exists" do
      let(:feature) { create :feature, flag_in_counts: { "users" => 10 } }

      it "returns the value" do
        feature.flag_in_count_for("users").should eq 10
      end
    end
  end

  describe "#opt_out_count_for" do
    context "when a value does not exist" do
      let(:feature) { create :feature }

      it "returns 0" do
        feature.opt_out_count_for("users").should eq 0
      end
    end

    context "when a value exists" do
      let(:feature) { create :feature, opt_out_counts: { "users" => 10 } }

      it "returns the value" do
        feature.opt_out_count_for("users").should eq 10
      end
    end
  end


  describe "#match_id?" do
    let(:user)    { create :user }
    let(:user2)   { create :user }
    let(:feature) { create :feature }

    before do
      create(:flag_in_flag, flaggable: user, feature: feature)
    end

    context "when the feature exists for the instance" do
      it "returns true" do
        feature.match_id?(user).should be_true
      end
    end

    context "when the feature does not exist for the instance" do
      it "returns false" do
        feature.match_id?(user2).should be_false
      end
    end
  end

  describe "#match_percentage?" do
    let(:user)    { create :user }
    let(:feature) { create :feature }
    let!(:flag)   { create :percentage_flag, feature: feature, flaggable_type: user.class.to_s, percentage: 50 }

    context "when the user's ID matches `id % 10 < percentage / 10" do
      it "returns true" do
        user.stub(:id) { 1 }
        feature.match_percentage?(user).should be_true
      end
    end

    context "when the user's ID does not match `id % 10 < percentage / 10" do
      it "returns false" do
        user.stub(:id) { 5 }
        feature.match_percentage?(user).should be_false
      end
    end
  end

  describe "#match_database_group?" do
    let(:user)        { create :user, name: "foo" }
    let(:user2)       { create :user }
    let(:widget)      { create :widget }
    let(:feature)     { create :feature }
    let(:group)       { create :group }
    let!(:membership) { create :membership, group: group, member: user }
    let!(:flag)       { create :database_group_flag, feature: feature, flaggable_type: user.class.to_s, group: group }

    context "when the instance is in the group" do
      it "returns true" do
        feature.match_database_groups?(user).should be_true
      end
    end

    context "when the instance is not in the group" do
      it "returns false" do
        feature.match_database_groups?(user2).should be_false
      end
    end

    context "when the instance is not of the type of the group" do
      it "returns false" do
        feature.match_database_groups?(widget).should be_false
      end
    end
  end

  describe "#match_defined_groups?" do
    let(:user)    { create :user, name: "foo" }
    let(:user2)   { create :user }
    let(:widget)  { create :widget }
    let(:feature) { create :feature }
    let!(:flag)   { create :defined_group_flag, feature: feature, flaggable_type: user.class.to_s, group_name: "foo_users" }

    before do
      Detour.config.define_user_group "foo_users" do |user|
        user.name == "foo"
      end
    end

    context "when the instance matches the block" do
      it "returns true" do
        feature.match_defined_groups?(user).should be_true
      end
    end

    context "when the instance does not match the block" do
      it "returns false" do
        feature.match_defined_groups?(user2).should be_false
      end
    end

    context "when the instance is not of the type of the block" do
      it "returns false" do
        feature.match_defined_groups?(widget).should be_false
      end
    end
  end
end
