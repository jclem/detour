require "spec_helper"

describe Detour::DatabaseGroupFlag do
  it { should validate_presence_of :group_id }
  it { should validate_presence_of :flaggable_type }
  it { should validate_uniqueness_of(:feature_id).scoped_to(:group_id) }

  it { should allow_mass_assignment_of :group_id }

  it { should belong_to :group }
  it { should have_many(:memberships).through(:group) }

  describe "#members" do
    let(:flag) { create :database_group_flag }
    let!(:membership) { create :membership, group: flag.group }

    it "returns its membership members" do
      flag.members.should eq [membership.member]
    end
  end

  describe "#group_name" do
    let(:flag) { create :database_group_flag }

    it "returns the name of the group" do
      flag.group_name.should eq flag.group.name
    end
  end
end
