require "spec_helper"

describe Detour::Membership do
  subject { create :membership }

  it { should validate_presence_of :group_id }
  it { should validate_presence_of :member_id }
  it { should validate_presence_of :member_type }
  it { should validate_uniqueness_of(:member_id).scoped_to(:group_id) }

  it { should allow_mass_assignment_of :group_id }
  it { should allow_mass_assignment_of :member_key }
  it { should allow_mass_assignment_of :member_type }

  it { should belong_to :group }
  it { should belong_to(:member) }

  describe "before validating" do
    it "sets its member" do
      group = create(:group, flaggable_type: "User")
      user  = create(:user)
      membership = create(:membership, member: nil, group: group, member_key: user.id)
      membership.member_id.should eq user.id
    end

    context "when the member is not found" do
      let(:membership) { build :membership, member: nil, member_key: 1 }

      it "is invalidated" do
        membership.valid?
        membership.errors["User"].should eq ['"1" could not be found']
      end
    end
  end

  describe "validate #member_type" do
    let(:group) { create :group, flaggable_type: "User" }

    context "when its member_type matches its group's flaggable_type" do
      let(:user) { create :user }
      let(:membership) { build :membership, group: group, member: user }

      it "is valid" do
        membership.should be_valid
      end
    end

    context "when its member_type does not match its group's flaggable_type" do
      let(:widget) { create :widget }
      let(:membership) { build :membership, group: group, member: widget }

      it "is invalid" do
        membership.valid?
        membership.errors[:member_type].should eq ["must match the group's flaggable_type"]
      end
    end
  end
end
