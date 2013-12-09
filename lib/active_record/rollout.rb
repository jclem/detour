require "active_record"
require "active_record/rollout/version"
require "active_record/rollout/feature"
require "active_record/rollout/flag"
require "active_record/rollout/flaggable"
require "active_record/rollout/opt_out"

class ActiveRecord::Rollout
  def self.configure(&block)
    yield ActiveRecord::Rollout::Feature
  end
end
