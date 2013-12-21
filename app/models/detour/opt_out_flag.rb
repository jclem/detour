# Ensures that a feature will never be available to the associated record,
# even in the case of, for example, a 100% flag.
class Detour::OptOutFlag < Detour::Flag
  include Detour::CountableFlag

  belongs_to :flaggable, polymorphic: true

  validates_presence_of   :flaggable
  validates_uniqueness_of :feature_id, scope: [:flaggable_type, :flaggable_id]

  attr_accessible :flaggable
end
