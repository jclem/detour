require "active_record/rollout"
require "rails/generators"
require "rails/generators/active_record"

class ActiveRecordRolloutGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration

  source_root File.expand_path("../templates", __FILE__)

  desc "Creates migration for ActiveRecord::Rollout"
  def create_migration_file
    migration_template "migration.rb", "db/migrate/setup_active_record_rollout.rb"
  end

  desc "Sets up an initializer for ActiveRecord::Rollout"
  def create_initializer
    copy_file "active_record_rollout.rb", "config/initializers/active_record_rollout.rb"
  end
end
