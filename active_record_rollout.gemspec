# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/rollout/version'

Gem::Specification.new do |spec|
  spec.name          = "active_record_rollout"
  spec.version       = ActiveRecord::Rollout::VERSION
  spec.authors       = ["Jonathan Clem"]
  spec.email         = ["jonathan@heroku.com"]
  spec.summary       = %q{Rollouts (feature flags) for ActiveRecord models.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "activerecord", ">= 3.2"
  spec.add_dependency "rails", ">= 3.2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "sqlite3-ruby"
  spec.add_development_dependency "pry-debugger"
end
