require "spec_helper"

describe Detour::Group do
  it { should validate_presence_of   :name }
  it { should validate_presence_of   :flaggable_type }
  it { should validate_uniqueness_of(:name).scoped_to(:flaggable_type) }
  it { should ensure_inclusion_of(:flaggable_type).in_array(Detour.config.flaggable_types) }

  it { should accept_nested_attributes_for :memberships }

  it { should have_many(:memberships).dependent(:destroy) }
  it { should have_many(:database_group_flags).dependent(:destroy) }
  it { should allow_mass_assignment_of :name }
  it { should allow_mass_assignment_of :flaggable_type }

  describe "#to_s" do
    it "returns the group name" do
      group = create :group
      group.to_s.should eq group.name
    end
  end
end
