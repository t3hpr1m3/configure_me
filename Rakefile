require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

namespace :spec do
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_opts =  %w{--text-report --sort coverage}
    t.rcov_opts << %w{--exclude gems\/,spec\/}
  end
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = 'features --format progress'
end
