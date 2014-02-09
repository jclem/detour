require "spec_helper"
require "fakefs/spec_helpers"

describe Detour::Feature do
  it { should have_many(:flag_in_flags).dependent(:destroy) }
  it { should have_many(:database_group_flags).dependent(:destroy) }
  it { should have_many(:defined_group_flags).dependent(:destroy) }
  it { should have_many(:percentage_flags).dependent(:destroy) }
  it { should have_many(:opt_out_flags).dependent(:destroy) }
  it { should have_many(:flags).dependent(:destroy) }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should allow_mass_assignment_of :name }

  it { should allow_value("foo").for(:name) }
  it { should allow_value("foo_bar").for(:name) }
  it { should allow_value("foo-bar").for(:name) }
  it { should_not allow_value("foo-bar.").for(:name) }
  it { should_not allow_value("foo bar").for(:name) }

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
      Detour.config.feature_search_dirs = ["/foo/**/*.rb"]

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
end
