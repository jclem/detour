# A group of flaggable records of a given class may be flagged into a feature
# with this class.
class ActiveRecord::Rollout::GroupFlag < ActiveRecord::Rollout::Flag
  validates :group_name, presence: true
end
