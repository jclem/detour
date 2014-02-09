require "spec_helper"

describe Detour::Flag do
  it { should belong_to :feature }
  it { should validate_presence_of :feature }
  it { should validate_presence_of :flaggable_type }
  it { should allow_mass_assignment_of :flaggable_type }

  describe ".without_opt_outs" do
    let(:feature)  { create :feature }
    let(:feature2) { create :feature }
    let(:user)    { create :user }

    before do
      Detour.config.define_user_group("foo") { true }
      Detour.config.define_user_group("bar") { true }
      Detour.config.define_widget_group("baz") { true }

      @flag1 = create :defined_group_flag, feature: feature, flaggable_type: "User", group_name: "foo"
      @flag2 = create :defined_group_flag, feature: feature2, flaggable_type: "User", group_name: "bar"
      @flag3 = create :defined_group_flag, feature: feature, flaggable_type: "Widget", group_name: "bar"
      create :opt_out_flag, feature: feature2, flaggable: user
    end

    it "returns flags without opt outs" do
      Detour::DefinedGroupFlag.without_opt_outs(user).should eq [@flag1]
    end
  end
end
