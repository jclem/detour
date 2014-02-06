# A group of flaggable records of a given class may be flagged into a feature
# with this class.
class Detour::DefinedGroupFlag < Detour::Flag
  include Detour::Concerns::Keepable

  validates_presence_of   :group_name
  validates_uniqueness_of :feature_id, scope: [:flaggable_type, :group_name]

  attr_accessible :group_name

  def group
    find_group || build_group
  end

  def group_type
    "defined"
  end

  private

  def find_group
    Detour::DefinedGroup.by_type(flaggable_type)[group_name]
  end

  def build_group
    Detour::DefinedGroup.new(group_name, ->{})
  end
end
