ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "capybara/poltergeist"
require "database_cleaner"
require "rspec/rails"
require "rspec/autorun"
require "factory_girl_rails"
require "shoulda-matchers"
require "pry"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  Capybara.javascript_driver = :poltergeist

  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.color = true
  config.order = "random"
  config.include FactoryGirl::Syntax::Methods

  I18n.enforce_available_locales = false

  config.after :each do
    Rake::Task.tasks.each { |t| t.reenable }
  end

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before :each do
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each, js: true do
    DatabaseCleaner.strategy = :truncation
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.before :each do
    User.instance_variable_set "@detour_flaggable_find_by", :id
    Detour.config.instance_variable_set "@defined_groups", {}
  end

  config.after :each do
    Detour.config.feature_search_dirs = []
    Detour.config.instance_variable_set "@defined_groups", {}
  end
end
