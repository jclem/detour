# Ensures that a feature will never be available to the associated record,
# even in the case of, for example, a 100% flag.
class ActiveRecord::Rollout::OptOutFlag < ActiveRecord::Rollout::Flag
  belongs_to :flaggable, polymorphic: true

  validates :flaggable_id, presence: true

  attr_accessible :flaggable
end
