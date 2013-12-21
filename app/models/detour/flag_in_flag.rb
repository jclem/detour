# An individual record of a certain type may be flagged into a feature with
# this class.
class Detour::FlagInFlag < Detour::Flag
  belongs_to :flaggable, polymorphic: true

  validates :flaggable,  presence: true
  validates :feature_id, uniqueness: { scope: [:flaggable_type, :flaggable_id] }

  attr_accessible :flaggable

  after_save do
    count = feature.flag_in_count_for(flaggable_type.tableize)
    feature.flag_in_counts[flaggable_type.tableize] = count + 1
    feature.save!
  end

  after_destroy do
    count = feature.flag_in_count_for(flaggable_type.tableize)
    feature.flag_in_counts[flaggable_type.tableize] = count - 1 < 0 ? 0 : count - 1
    feature.save!
  end
end
