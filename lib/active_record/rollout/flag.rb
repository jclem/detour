class ActiveRecord::Rollout::Flag < ActiveRecord::Base
  self.table_name = :active_record_rollout_flags

  belongs_to :rollout
  belongs_to :flag_subject, polymorphic: true

  validates :rollout_id, presence: true
end
