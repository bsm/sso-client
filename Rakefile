require 'rake'
require 'rspec/mocks/version'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

include Rake::DSL
RSpec::Core::RakeTask.new(:spec)

desc 'Default: run specs.'
task :default => :spec
