require "spec_helper"

describe ActiveRecord::Rollout::Feature do
  it { should have_many(:flags).dependent(:destroy) }
  it { should have_many(:opt_outs).dependent(:destroy) }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  describe ".add_{klass}" do
    let(:user) { User.create }

    it "creates a flag from the given instance" do
      ActiveRecord::Rollout::Feature.should_receive(:create_flag_from_instance).with user, :foo
      ActiveRecord::Rollout::Feature.add_user user, :foo
    end
  end

  describe ".remove_{klass}" do
    let(:user) { User.create }

    it "removes a flag from the given instance" do
      ActiveRecord::Rollout::Feature.should_receive(:remove_flag_from_instance).with user, :foo
      ActiveRecord::Rollout::Feature.remove_user user, :foo
    end
  end

  describe ".define_{klass}_group" do
    let(:block) { Proc.new {} }
    it "defines a group for the given class" do
      ActiveRecord::Rollout::Feature.should_receive(:define_group_for_class).with("User", :id_is_1)
      ActiveRecord::Rollout::Feature.define_user_group :id_is_1, block
    end
  end

  describe ".create_flag_from_instance" do
    let(:user) { User.create }
    let!(:feature) { ActiveRecord::Rollout::Feature.create!(name: "foo") }

    before do
      ActiveRecord::Rollout::Feature.create_flag_from_instance user, :foo
    end

    it "creats a flag for the given instance and feature" do
      user.features.should include feature
    end
  end

  describe ".remove_flag_from_instance" do
    let(:user) { User.create }
    let!(:feature) { ActiveRecord::Rollout::Feature.create!(name: "foo") }

    before do
      ActiveRecord::Rollout::Feature.add_user(user, :foo)
      ActiveRecord::Rollout::Feature.remove_flag_from_instance(user, :foo)
    end

    it "creats a flag for the given instance and feature" do
      user.features.should_not include feature
    end
  end

  describe ".define_group_for_class" do
    let(:block) { Proc.new {} }
    before do
      ActiveRecord::Rollout::Feature.define_group_for_class "User", "user_id_1", &block
    end

    it "defines a group for the given class" do
      ActiveRecord::Rollout::Feature.defined_groups["User"].should eq({ "user_id_1" => block })
    end
  end

  describe "#match?" do
    let(:user) { User.create }
    let(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

    it "checks if the user is flagged individually" do
      feature.should_receive(:match_instance?).with(user)
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

  describe "#match_instance?" do
    let(:user) { User.create }
    let(:user2) { User.create }
    let!(:feature) { ActiveRecord::Rollout::Feature.create!(name: "foo") }

    before do
      ActiveRecord::Rollout::Feature.add_user(user, :foo)
    end

    context "when the feature exists for the instance" do
      it "returns true" do
        feature.match_instance?(user).should be_true
      end
    end

    context "when the feature does not exist for the instance" do
      it "returns false" do
        feature.match_instance?(user2).should be_false
      end
    end
  end

  describe "#match_percentage?" do
    let(:user) { User.create }
    let(:feature) { ActiveRecord::Rollout::Feature.create!(name: "foo") }
    let!(:flag) { feature.flags.create(percentage_type: "User", percentage: 50) }

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
    let(:feature) { ActiveRecord::Rollout::Feature.create!(name: "baz") }
    let!(:flag) { feature.flags.create(group_type: "User", group_name: "foo_users") }

    before do
      ActiveRecord::Rollout::Feature.define_user_group "foo_users" do |user|
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
