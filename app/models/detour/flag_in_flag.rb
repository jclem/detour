# An individual record of a certain type may be flagged into a feature with
# this class.
class Detour::FlagInFlag < Detour::Flag
  include Detour::Concerns::CountableFlag

  belongs_to :flaggable, polymorphic: true

  validates_presence_of   :flaggable
  validates_uniqueness_of :feature_id, scope: [:flaggable_type, :flaggable_id]

  attr_accessible :flaggable
end
