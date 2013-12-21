# An individual record of a certain type may be flagged into a feature with
# this class.
class Detour::FlagInFlag < Detour::Flag
  include Detour::CountableFlag

  belongs_to :flaggable, polymorphic: true

  validates :flaggable,  presence: true
  validates :feature_id, uniqueness: { scope: [:flaggable_type, :flaggable_id] }

  attr_accessible :flaggable
end
