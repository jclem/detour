require "active_record/rollout/version"
require "active_record/rollout/flag"

class ActiveRecord::Rollout < ActiveRecord::Base
  self.table_name = :active_record_rollouts

  has_many :flags, dependent: :destroy

  validates :name, presence: true
end
