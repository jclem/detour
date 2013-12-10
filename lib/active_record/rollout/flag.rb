# Indicates that a specific feature has been rolled out to an individual
# Table for storing flaggable flag-ins, group flag-ins, or percentage-based
# flag-ins.
class ActiveRecord::Rollout::Flag < ActiveRecord::Base
  self.table_name = :active_record_rollout_flags

  belongs_to :feature
  validates :feature_id, presence: true
  validates :flaggable_type, presence: true
end
