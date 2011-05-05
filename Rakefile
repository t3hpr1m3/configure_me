require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

namespace :spec do
  desc 'Generate coverage information with rcov'
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_opts =  %w{--text-report --sort coverage}
    t.rcov_opts << %w{--exclude gems\/,spec\/}
  end
end
