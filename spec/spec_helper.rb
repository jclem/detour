require "active_record"
require "active_record/rollout"
require "shoulda-matchers"
require "generators/templates/migration"
require "pry"

class User < ActiveRecord::Base
  include ActiveRecord::Rollout::Flaggable
end

class Organization < ActiveRecord::Base
  include ActiveRecord::Rollout::Flaggable
end

RSpec.configure do |config|
  config.before :suite do
    ActiveRecord::Base.establish_connection \
      adapter: "sqlite3",
      database: File.dirname(__FILE__) + "/spec.sqlite3"

    require File.dirname(__FILE__) + "/support/schema.rb"
  end

  config.before :each do
    ActiveRecordRolloutMigration.migrate :up
    ActiveRecord::Schema.migrate :up
  end

  config.after :each do
    ActiveRecordRolloutMigration.migrate :down
    ActiveRecord::Schema.migrate :down
  end

  config.after :each do
    ActiveRecord::Rollout::Feature.class_variable_set "@@defined_groups", {}
  end
end
