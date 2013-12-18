require "rake"

APP_RAKEFILE = File.expand_path("../../../../spec/dummy/Rakefile", __FILE__)
load "rails/tasks/engine.rake"

# Hat tip: http://robots.thoughtbot.com/test-rake-tasks-like-a-boss
shared_context "rake" do
  let(:task_name) { self.class.top_level_description }
  subject         { Rake::Task["app:#{task_name}"] }
end
