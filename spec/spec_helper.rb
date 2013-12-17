require "rails"
require "active_record"
require "detour"
require "shoulda-matchers"
require "generators/templates/migration"
require "support/shared_contexts/rake"
require "pry"

class User < ActiveRecord::Base
  acts_as_flaggable
end

class Organization < ActiveRecord::Base
  acts_as_flaggable
end

RSpec.configure do |config|
  config.before :suite do
    ActiveRecord::Base.establish_connection \
      adapter: "sqlite3",
      database: File.dirname(__FILE__) + "/spec.sqlite3"

    require File.dirname(__FILE__) + "/support/schema.rb"
  end

  config.before :each do
    SetupDetour.migrate :up
    ActiveRecord::Schema.migrate :up
  end

  config.after :each do
    SetupDetour.migrate :down
    ActiveRecord::Schema.migrate :down
  end

  config.after :each do
    Detour::Feature.instance_variable_set "@defined_groups", {}
    Detour::Feature.instance_variable_set "@default_flaggable_class_name", nil
  end
end
