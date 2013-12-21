# Indicates that a specific feature has been rolled out to an individual
# Table for storing flaggable flag-ins, group flag-ins, or percentage-based
# flag-ins.
class Detour::Flag < ActiveRecord::Base
  self.table_name = :detour_flags

  belongs_to :feature

  validates :feature, presence: true
  validates :flaggable_type, presence: true

  attr_accessible :flaggable_type

  private

  def flag_type
    self.class.to_s.underscore.gsub("detour/", "").split("_")[0..-2].join("_")
  end
end
