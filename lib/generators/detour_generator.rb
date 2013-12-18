require "detour"
require "rails/generators"
require "rails/generators/active_record"

class DetourGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration

  source_root File.expand_path("../templates", __FILE__)

  desc "Creates migration for Detour"
  def create_migration_file
    migration_template "migration.rb", "db/migrate/setup_detour.rb"
  end

  desc "Sets up an initializer for Detour"
  def create_initializer
    copy_file "detour.rb", "config/initializers/detour.rb"
  end
end
