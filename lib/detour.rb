require "detour/engine"
require "detour/acts_as_flaggable"
require "detour/flaggable"

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
    ActionDispatch::Reloader.to_prepare do
      yield Detour::Feature
    end
  end
end

# class Detour::Task < Rails::Railtie
  # rake_tasks do
    # Dir[File.join(File.dirname(__FILE__), '../tasks/*.rake')].each { |f| load f }
  # end
# end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Detour::ActsAsFlaggable
end
