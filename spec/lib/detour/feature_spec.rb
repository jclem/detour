require "spec_helper"
require "fakefs/spec_helpers"

describe Detour::Feature do
  it { should have_many(:flaggable_flags) }
  it { should have_many(:group_flags) }
  it { should have_many(:percentage_flags) }
  it { should have_many(:opt_out_flags) }
  it { should have_many(:flags).dependent(:destroy) }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should allow_mass_assignment_of :name }

  describe ".all_with_lines" do
    include FakeFS::SpecHelpers

    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.grep_dirs = ["/foo/**/*.rb"]

      FileUtils.mkdir("/foo")

      File.open("/foo/bar.rb", "w") do |file|
        file.write <<-EOF
          current_user.has_feature?(:foo) do
          end

          current_user.has_feature?(:bar) do
          end

          current_user.has_feature?(:foo) do
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

    it "fetches lines for persisted features" do
      persisted_feature = Detour::Feature.all_with_lines.detect { |f| f.name == feature.name }
      persisted_feature.lines.should eq %w[/foo/bar.rb#L1 /foo/bar.rb#L7 /foo/baz.rb#L1]
    end

    it "fetches lines for un-persisted features" do
      unpersisted_feature = Detour::Feature.all_with_lines.detect { |f| f.name == "bar" }
      unpersisted_feature.lines.should eq %w[/foo/bar.rb#L4 /foo/baz.rb#L1 /foo/baz.rb#L3]
    end
  end

  describe ".define_{klass}_group" do
    let(:block) { Proc.new {} }
    it "defines a group for the given class" do
      Detour::Feature.should_receive(:define_group_for_class).with("User", :id_is_1)
      Detour::Feature.define_user_group :id_is_1, block
    end
  end

  describe ".add_record_to_feature" do
    let(:user) { User.create }
    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.add_record_to_feature user, :foo
    end

    it "creates a flag for the given instance and feature" do
      user.features.should include feature
    end
  end

  describe ".remove_record_from_feature" do
    let(:user) { User.create }
    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.add_record_to_feature user, :foo
      Detour::Feature.remove_record_from_feature user, :foo
    end

    it "creates a flag for the given instance and feature" do
      user.features.should_not include feature
    end
  end

  describe ".opt_record_out_of_feature" do
    let(:user) { User.create }
    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.add_percentage_to_feature "User", 100, "foo"
      Detour::Feature.opt_record_out_of_feature user, "foo"
    end

    it "opts the record out of the feature" do
      user.has_feature?("foo").should be_false
    end
  end

  describe ".un_opt_record_out_of_feature" do
    let(:user) { User.create }
    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.add_percentage_to_feature "User", 100, "foo"
      Detour::Feature.opt_record_out_of_feature user, "foo"
      Detour::Feature.un_opt_record_out_of_feature user, "foo"
    end

    it "opts the record out of the feature" do
      user.has_feature?("foo").should be_true
    end
  end

  describe ".add_group_to_feature" do
    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.define_user_group :bar do
      end
      Detour::Feature.add_group_to_feature "User", :bar, "foo"
    end

    it "creates a flag for the given group and feature" do
      feature.group_flags.where(flaggable_type: "User", group_name: "bar").first.should_not be_nil
    end
  end

  describe ".remove_group_from_feature" do
    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.define_user_group :bar do
      end
      Detour::Feature.add_group_to_feature "User", :bar, "foo"
      Detour::Feature.remove_group_from_feature "User", :bar, "foo"
    end

    it "destroys flags for the given group and feature" do
      feature.group_flags.where(flaggable_type: "User", group_name: "bar").first.should be_nil
    end
  end

  describe ".add_percentage_to_feature" do
    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.add_percentage_to_feature "User", 50, "foo"
    end

    it "creates a flag for the given percentage and feature" do
      feature.percentage_flags.where(flaggable_type: "User", percentage: 50).first.should_not be_nil
    end
  end

  describe ".remove_percentage_from_feature" do
    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.add_percentage_to_feature "User", 50, "foo"
      Detour::Feature.remove_percentage_from_feature "User", "foo"
    end

    it "creates a flag for the given percentage and feature" do
      feature.percentage_flags.where(flaggable_type: "User").first.should be_nil
    end
  end

  describe ".define_group_for_class" do
    let(:block) { Proc.new {} }
    before do
      Detour::Feature.send :define_group_for_class, "User", "user_id_1", &block
    end

    it "defines a group for the given class" do
      Detour::Feature.defined_groups["User"].should eq({ "user_id_1" => block })
    end
  end

  describe "#match?" do
    let(:user) { User.create }
    let(:feature) { Detour::Feature.create(name: "foo") }

    it "checks if the user is flagged individually" do
      feature.should_receive(:match_id?).with(user)
      feature.match?(user)
    end

    it "checks if the user is flagged as part of a percentage" do
      feature.should_receive(:match_percentage?).with(user)
      feature.match?(user)
    end

    it "checks if the user is flagged as part of a group" do
      feature.should_receive(:match_groups?).with(user)
      feature.match?(user)
    end
  end

  describe "#match_id?" do
    let(:user) { User.create }
    let(:user2) { User.create }
    let!(:feature) { Detour::Feature.create!(name: "foo") }

    before do
      Detour::Feature.add_record_to_feature user, :foo
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
    let(:user) { User.create }
    let(:feature) { Detour::Feature.create!(name: "foo") }
    let!(:flag) { feature.percentage_flags.create(flaggable_type: "User", percentage: 50) }

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

  describe "#match_groups?" do
    let!(:user) { User.create(name: "foo") }
    let!(:user2) { User.create(name: "bar") }
    let!(:organization) { Organization.create(name: "foo") }
    let(:feature) { Detour::Feature.create!(name: "baz") }
    let!(:flag) { feature.group_flags.create(flaggable_type: "User", group_name: "foo_users") }

    before do
      Detour::Feature.define_user_group "foo_users" do |user|
        user.name == "foo"
      end
    end

    context "when the instance matches the block" do
      it "returns true" do
        feature.match_groups?(user).should be_true
      end
    end

    context "when the instance does not match the block" do
      it "returns false" do
        feature.match_groups?(user2).should be_false
      end
    end

    context "when the instance is not of the type of the block" do
      it "returns false" do
        feature.match_groups?(organization).should be_false
      end
    end
  end
end
