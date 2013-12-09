class ActiveRecord::Rollout::OptOut < ActiveRecord::Base
  self.table_name = :active_record_rollout_opt_outs

  belongs_to :rollout
  belongs_to :opt_out_subject, polymorphic: true

  validates :rollout_id, presence: true
end
