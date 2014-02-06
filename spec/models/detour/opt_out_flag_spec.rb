require "spec_helper"

describe Detour::OptOutFlag do
  it { should be_a Detour::FlaggableFlag }

  it "validates uniquness of feature_id on flaggable" do
    user  = create :user
    flag  = create :opt_out_flag, flaggable: user
    flag2 = build  :opt_out_flag, flaggable: user, feature: flag.feature

    flag2.should_not be_valid
    flag2.errors.full_messages.should eq ["Feature has already been taken"]
  end

  describe "when creating" do
    let(:flag) { create :opt_out_flag }

    it "increments its feature's opt_out_count" do
      flag.reload.feature.opt_out_count_for(flag.flaggable_type.tableize).should eq 1
    end
  end

  describe "when destroying" do
    let!(:flag)  { create  :opt_out_flag }
    let!(:flag2) { create  :opt_out_flag, feature: flag.feature }

    before do
      flag2.destroy
    end

    it "decrements its feature's opt_out_count" do
      flag.reload.feature.opt_out_count_for(flag.flaggable_type.tableize).should eq 1
    end
  end
end
