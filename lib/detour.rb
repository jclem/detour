require "detour/engine"
require "detour/acts_as_flaggable"
require "detour/flaggable"
require "detour/configuration"

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
      yield Detour.config
    end
  end

  def self.config
    @config ||= Detour::Configuration.new
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Detour::ActsAsFlaggable
end
