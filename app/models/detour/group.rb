class Detour::Group < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :memberships

  def to_s
    name
  end
end
