require "spec_helper"

describe Detour::Group do
  it { should validate_presence_of   :name }
  it { should validate_uniqueness_of :name }
  it { should have_many(:memberships).dependent(:destroy) }
  it { should allow_mass_assignment_of :name }

  describe "#to_s" do
    it "returns the group name" do
      group = create :group
      group.to_s.should eq group.name
    end
  end
end
