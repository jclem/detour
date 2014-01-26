class Detour::DatabaseGroupFlag < Detour::Flag
  validates_presence_of   :group_id
  validates_presence_of   :flaggable_type
  validates_uniqueness_of :feature_id, scope: :group_id

  attr_writer     :to_keep
  attr_accessible :group_id

  belongs_to :group

  def to_keep
    @to_keep || (!marked_for_destruction? && !new_record?)
  end
end
