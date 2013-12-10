require "active_record"
require "active_record/rollout/version"
require "active_record/rollout/feature"
require "active_record/rollout/flag"
require "active_record/rollout/flaggable_flag"
require "active_record/rollout/group_flag"
require "active_record/rollout/percentage_flag"
require "active_record/rollout/opt_out_flag"
require "active_record/rollout/flaggable"
require "active_record/rollout/acts_as_flaggable"

class ActiveRecord::Rollout
  # Allows for configuration of ActiveRecord::Rollout::Feature, mostly intended
  # for defining groups:
  #
  # @example
  #   ActiveRecord::Rollout.configure do |config|
  #     config.define_user_group :admins do |user|
  #       user.admin?
  #     end
  #   end
  def self.configure(&block)
    yield ActiveRecord::Rollout::Feature
  end
end

class ActiveRecord::Rollout::Task < Rails::Railtie
  rake_tasks do
    Dir[File.join(File.dirname(__FILE__), '../tasks/*.rake')].each { |f| load f }
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend ActiveRecord::Rollout::ActsAsFlaggable
end
