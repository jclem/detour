require "spec_helper"

describe ActiveRecord::Rollout do
  it { should be_a ActiveRecord::Base }
  it { should have_many(:flags).dependent(:destroy) }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  describe ".add_{klass}" do
    let(:user) { User.create }

    it "creates a flag from the given instance" do
      ActiveRecord::Rollout.should_receive(:create_flag_from_instance).with user, :foo
      ActiveRecord::Rollout.add_user user, :foo
    end
  end

  describe ".remove_{klass}" do
    let(:user) { User.create }

    it "removes a flag from the given instance" do
      ActiveRecord::Rollout.should_receive(:remove_flag_from_instance).with user, :foo
      ActiveRecord::Rollout.remove_user user, :foo
    end
  end

  describe ".create_flag_from_instance" do
    let(:user) { User.create }
    let!(:rollout) { ActiveRecord::Rollout.create!(name: "foo") }

    before do
      ActiveRecord::Rollout.create_flag_from_instance user, :foo
    end

    it "creats a flag for the given instance and rollout" do
      user.rollouts.should include rollout
    end
  end

  describe ".remove_flag_from_instance" do
    let(:user) { User.create }
    let!(:rollout) { ActiveRecord::Rollout.create!(name: "foo") }

    before do
      ActiveRecord::Rollout.add_user(user, :foo)
      ActiveRecord::Rollout.remove_flag_from_instance(user, :foo)
    end

    it "creats a flag for the given instance and rollout" do
      user.rollouts.should_not include rollout
    end
  end

  describe "#match_{klass}?" do
    let(:rollout) { ActiveRecord::Rollout.create(name: "foo") }
    let(:user) { User.create }

    it "matches a flag forfrom the given instance" do
      rollout.should_receive(:match_instance?).with user
      rollout.match_user? user
    end
  end

  describe "#match_instance?" do
    let(:user) { User.create }
    let(:user2) { User.create }
    let!(:rollout) { ActiveRecord::Rollout.create!(name: "foo") }

    before do
      ActiveRecord::Rollout.add_user(user, :foo)
    end

    context "when the rollout exists for the instance" do
      it "returns true" do
        rollout.match_instance?(user).should be_true
      end
    end

    context "when the rollout does not exist for the instance" do
      it "returns false" do
        rollout.match_instance?(user2).should be_false
      end
    end
  end

  describe "#match_percentage?" do
    let(:user) { User.create }
    let(:rollout) { ActiveRecord::Rollout.create!(name: "foo") }
    let!(:flag) { rollout.flags.create(percentage_type: "User", percentage: 50) }

    context "when the user's ID matches `id % 10 < percentage / 10" do
      it "returns true" do
        user.stub(:id) { 1 }
        rollout.match_percentage?(user).should be_true
      end
    end

    context "when the user's ID does not match `id % 10 < percentage / 10" do
      it "returns false" do
        user.stub(:id) { 5 }
        rollout.match_percentage?(user).should be_false
      end
    end
  end
end
