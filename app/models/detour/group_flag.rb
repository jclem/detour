# A group of flaggable records of a given class may be flagged into a feature
# with this class.
class Detour::GroupFlag < Detour::Flag
  validates_presence_of   :group_name
  validates_uniqueness_of :feature_id, scope: [:flaggable_type, :group_name]

  attr_writer     :to_keep
  attr_accessible :group_name

  def to_keep
    @to_keep || (!marked_for_destruction? && !new_record?)
  end
end
