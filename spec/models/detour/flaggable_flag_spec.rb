require "spec_helper"

describe Detour::FlaggableFlag do
  it { should belong_to :flaggable }
  it { should validate_presence_of :flaggable }
  it { should allow_mass_assignment_of :flaggable }

  describe "before validating" do
    it "sets its flaggable" do
      feature = create(:feature)
      user    = create(:user)
      flag    = create(:flag_in_flag, flaggable: nil, feature: feature, flaggable_key: user.id, flaggable_type: "User")
      flag.flaggable_id.should eq user.id
    end

    context "when the flaggable is not found" do
      let(:flag) { build :flag_in_flag, flaggable: nil, flaggable_key: 1, flaggable_type: "User" }

      it "is invalidated" do
        flag.valid?
        flag.errors["User"].should eq ['"1" could not be found']
      end
    end
  end
end
