class Detour::Membership < ActiveRecord::Base
  validates :group_id,    presence: true, uniqueness: { scope: [:member_id, :member_type] }
  validates :member_id,   presence: true
  validates :member_type, presence: true

  attr_accessible :group_id
  attr_accessible :member_id
  attr_accessible :member_type

  default_scope { order("member_type ASC") }

  belongs_to :group
  belongs_to :member, polymorphic: true
end
