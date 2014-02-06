# Ensures that a feature will never be available to the associated record,
# even in the case of, for example, a 100% flag.
class Detour::OptOutFlag < Detour::FlaggableFlag
  validates_uniqueness_of :feature_id, scope: [:flaggable_type, :flaggable_id]
end
