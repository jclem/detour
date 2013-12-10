# An individual record of a certain type may be flagged into a feature with
# this class.
class ActiveRecord::Rollout::FlaggableFlag < ActiveRecord::Rollout::Flag
  belongs_to :flaggable, polymorphic: true

  validates :flaggable_id, presence: true

  attr_accessible :flaggable
end
