require "spec_helper"

describe Detour::Membership do
  it { should validate_presence_of :group_id }
  it { should validate_presence_of :member_id }
  it { should validate_presence_of :member_type }
  it { should validate_uniqueness_of(:group_id).scoped_to [:member_id, :member_type] }

  it { should allow_mass_assignment_of :group_id }
  it { should allow_mass_assignment_of :member_id }
  it { should allow_mass_assignment_of :member_type }

  it { should belong_to :group }
  it { should belong_to :member }
end
