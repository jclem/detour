# A percentage of flaggable records of a given class may be flagged into a feature
# with this class.
class Detour::PercentageFlag < Detour::Flag
  validates_presence_of     :percentage
  validates_numericality_of :percentage, greater_than: 0, less_than_or_equal_to: 100
  validates_uniqueness_of   :feature_id, scope: :flaggable_type

  attr_accessible :percentage
end
