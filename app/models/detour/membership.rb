class Detour::Membership < ActiveRecord::Base
  validates :group_id,    presence: true
  validates :member_id,   presence: true, uniqueness: { scope: :group_id }
  validates :member_key,  presence: true, unless: -> { member_id }
  validates :member_type, presence: true
  validate  :validate_member_type

  attr_accessor   :member_key
  attr_accessible :group_id
  attr_accessible :member_key
  attr_accessible :member_type

  default_scope { order("member_type ASC") }

  belongs_to :group
  belongs_to :member, polymorphic: true

  before_validation :set_member

  private

  def member_class
    group.flaggable_class
  end

  def set_member
    unless member || !member_key
      self.member_type = group.flaggable_type
      self.member_id   = member_class.flaggable_find!(member_key).id
    end
  rescue ActiveRecord::RecordNotFound
    errors.add(member_type, "\"#{member_key}\" could not be found")
    false
  end

  def validate_member_type
    unless group && member_type == group.flaggable_type
      errors.add :member_type, "must match the group's flaggable_type"
    end
  end
end
