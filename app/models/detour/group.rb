class Detour::Group < ActiveRecord::Base
  validates :name,           presence: true, uniqueness: { scope: :flaggable_type }
  validates :flaggable_type, presence: true, inclusion: { in: Detour.config.flaggable_types }
  has_many :memberships, dependent: :destroy

  accepts_nested_attributes_for :memberships, allow_destroy: true

  attr_accessible :name, :flaggable_type, :memberships_attributes

  def to_s
    name
  end

  def flaggable_class
    flaggable_type.constantize
  end
end
