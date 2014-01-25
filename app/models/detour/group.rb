class Detour::Group < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :memberships, dependent: :destroy

  attr_accessible :name

  def to_s
    name
  end
end
