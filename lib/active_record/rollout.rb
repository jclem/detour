require "active_record/rollout/version"
require "active_record/rollout/flag"
require "active_record/rollout/flaggable"

class ActiveRecord::Rollout < ActiveRecord::Base
  self.table_name = :active_record_rollouts

  has_many :flags, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def self.method_missing(method, *args, &block)
    if method =~ /^add_.*/
      create_flag_from_instance(args[0], args[1])
    else
      super
    end
  end

  def self.create_flag_from_instance(instance, flag_name)
    rollout = ActiveRecord::Rollout.find_by!(name: flag_name)
    rollout.flags.create!(flag_subject: instance)
  end
end
