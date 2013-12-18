# Ensures that a feature will never be available to the associated record,
# even in the case of, for example, a 100% flag.
class Detour::OptOutFlag < Detour::Flag
  belongs_to :flaggable, polymorphic: true

  validates :flaggable_id, presence: true
  validates :feature_id, uniqueness: { scope: [:flaggable_type, :flaggable_id] }

  attr_accessible :flaggable
end
