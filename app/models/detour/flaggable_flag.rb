# An individual record of a certain type may be flagged into a feature with
# this class.
class Detour::FlaggableFlag < Detour::Flag
  belongs_to :flaggable, polymorphic: true

  validates :flaggable_id, presence: true
  validates :feature_id, uniqueness: { scope: [:flaggable_type, :flaggable_id] }

  attr_accessible :flaggable
end
