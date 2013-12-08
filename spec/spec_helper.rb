require "active_record"
require "active_record/rollout"
require "shoulda-matchers"

RSpec.configure do |config|
  config.before :suite do
    ActiveRecord::Base.establish_connection \
      adapter: "sqlite3",
      database: File.dirname(__FILE__) + "/spec.sqlite3"

    load File.dirname(__FILE__) + "/support/schema.rb"
  end

  config.after :suite do
    ActiveRecordRolloutMigration.migrate(:down)
  end
end
