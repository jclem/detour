require "spec_helper"

describe Detour::FlaggableFlag do
  it { should be_a Detour::Flag }
  it { should belong_to :flaggable }
  it { should validate_presence_of :flaggable }
  it { should allow_mass_assignment_of :flaggable }

  it "validates uniquness of feature_id on flaggable" do
    user  = create :user
    flag  = create :flaggable_flag, flaggable: user
    flag2 = build  :flaggable_flag, flaggable: user, feature: flag.feature

    flag2.should_not be_valid
    flag2.errors.full_messages.should eq ["Feature has already been taken"]
  end

  describe "when creating" do
    let(:flag) { create :flaggable_flag }

    it "increments its feature's flag_in_count" do
      flag.reload.feature.flag_in_count_for(flag.flaggable_type.tableize).should eq 1
    end
  end

  describe "when destroying" do
    let!(:flag)  { create  :flaggable_flag }
    let!(:flag2) { create  :flaggable_flag, feature: flag.feature }

    before do
      flag2.destroy
    end

    it "decrements its feature's flag_in_count" do
      flag.reload.feature.flag_in_count_for(flag.flaggable_type.tableize).should eq 1
    end
  end
end
