require "active_record"
require "detour/version"
require "detour/feature"
require "detour/flag"
require "detour/flaggable_flag"
require "detour/group_flag"
require "detour/percentage_flag"
require "detour/opt_out_flag"
require "detour/flaggable"
require "detour/acts_as_flaggable"

module Detour
  # Allows for configuration of Detour::Feature, mostly intended
  # for defining groups:
  #
  # @example
  #   Detour.configure do |config|
  #     config.define_user_group :admins do |user|
  #       user.admin?
  #     end
  #   end
  def self.configure(&block)
    yield Detour::Feature
  end
end

class Detour::Task < Rails::Railtie
  rake_tasks do
    Dir[File.join(File.dirname(__FILE__), '../tasks/*.rake')].each { |f| load f }
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Detour::ActsAsFlaggable
end
