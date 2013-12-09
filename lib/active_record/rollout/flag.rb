# Indicates that a specific feature has been rolled out to an individual
# record, a percentage of records, or a group of records.
class ActiveRecord::Rollout::Flag < ActiveRecord::Base
  self.table_name = :active_record_rollout_flags

  belongs_to :feature
  belongs_to :flag_subject, polymorphic: true

  validates :feature_id, presence: true
end
