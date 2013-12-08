require "active_record/rollout"
require "rails/generators"
require "rails/generators/active_record"

class ActiveRecord::Rollout::Generator < Rails::Generators::Base
  include ActiveRecord::Generators::Migration
  extend ActiveRecord::Generators::Migration

  source_root File.expand_path("../templates" __FILE__)

  desc "Creates migration for ActiveRecord::Rollout"
  def create_migration_file
    migration_template "migration.rb", "db/migrations/active_record_rollout"
  end
end
