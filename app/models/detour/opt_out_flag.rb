# Ensures that a feature will never be available to the associated record,
# even in the case of, for example, a 100% flag.
class Detour::OptOutFlag < Detour::Flag
  belongs_to :flaggable, polymorphic: true

  validates :flaggable, presence: true
  validates :feature_id, uniqueness: { scope: [:flaggable_type, :flaggable_id] }

  attr_accessible :flaggable

  after_save do
    count = feature.opt_out_count_for(flaggable_type.tableize)
    feature.opt_out_counts[flaggable_type.tableize] = count + 1
    feature.save!
  end

  after_destroy do
    count = feature.opt_out_count_for(flaggable_type.tableize)
    feature.opt_out_counts[flaggable_type.tableize] = count - 1 < 0 ? 0 : count - 1
    feature.save!
  end
end
