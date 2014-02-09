# Indicates that a specific feature has been rolled out to an individual
# Table for storing flaggable flag-ins, group flag-ins, or percentage-based
# flag-ins.
class Detour::Flag < ActiveRecord::Base
  self.table_name = :detour_flags

  belongs_to :feature

  validates_presence_of :feature
  validates_presence_of :flaggable_type

  attr_accessible :flaggable_type

  scope :without_opt_outs, ->(record) {
    where(flaggable_type: record.class.to_s).where <<-SQL
      feature_id NOT IN (
        SELECT feature_id FROM detour_flags
          WHERE detour_flags.type = 'Detour::OptOutFlag'
          AND   detour_flags.flaggable_type = '#{record.class.to_s}'
          AND   detour_flags.flaggable_id   = '#{record.id}'
      )
    SQL
  }

  private

  def flag_type
    self.class.to_s.underscore.gsub("detour/", "").split("_")[0..-2].join("_")
  end
end
