# A group of flaggable records of a given class may be flagged into a feature
# with this class.
class Detour::DefinedGroupFlag < Detour::Flag
  include Detour::Concerns::Keepable

  validates_presence_of   :group_name
  validates_uniqueness_of :feature_id, scope: [:flaggable_type, :group_name]

  attr_accessible :group_name

  def group
    Detour::DefinedGroup.by_type(flaggable_type)[group_name]
  end

  def group_type
    "defined"
  end
end
