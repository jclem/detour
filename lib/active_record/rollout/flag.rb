class ActiveRecord::Rollout::Flag < ActiveRecord::Base
  self.table_name = :active_record_rollout_flags

  belongs_to :rollout

  validates :rollout_id, presence: true
end
