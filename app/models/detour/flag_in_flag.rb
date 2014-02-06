# An individual record of a certain type may be flagged into a feature with
# this class.
class Detour::FlagInFlag < Detour::FlaggableFlag
  validates_uniqueness_of :feature_id, scope: [:flaggable_type, :flaggable_id]
end
