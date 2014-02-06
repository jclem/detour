class Detour::FlaggableFlag < Detour::Flag
  include Detour::Concerns::CountableFlag

  belongs_to :flaggable, polymorphic: true

  validates_presence_of :flaggable

  attr_accessor   :flaggable_key
  attr_accessible :flaggable
  attr_accessible :flaggable_key

  before_validation :set_flaggable

  private

  def set_flaggable
    unless flaggable || !flaggable_key
      self.flaggable_id = flaggable_type.constantize.flaggable_find!(flaggable_key).id
    end
  rescue ActiveRecord::RecordNotFound
    errors.add(flaggable_type, "\"#{flaggable_key}\" could not be found")
    false
  end
end
