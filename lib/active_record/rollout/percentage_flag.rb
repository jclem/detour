# A percentage of flaggable records of a given class may be flagged into a feature
# with this class.
class ActiveRecord::Rollout::PercentageFlag < ActiveRecord::Rollout::Flag
  validates :percentage,
    presence: true,
    numericality: { greater_than: 0, less_than_or_equal_to: 100 }

  validates :feature_id, uniqueness: { scope: :flaggable_type }

  attr_accessible :percentage
end
