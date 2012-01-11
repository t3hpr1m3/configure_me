# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "configure_me/version"

Gem::Specification.new do |s|
  s.name        = "configure_me"
  s.version     = ConfigureMe::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Josh Williams"]
  s.email       = ["theprime@codingprime.com"]
  s.homepage    = "http://www.github.com/t3hpr1m3/configure_me"
  s.summary     = %q{Simple configuration library}
  s.description = %q{Simple gem to assist with persisting configuration data.}

  s.rubyforge_project = "configure_me"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = %w(lib)

  s.add_dependency 'activerecord',    '~> 3.1.0'
  s.add_dependency 'activesupport',   '~> 3.1.0'

  s.add_development_dependency 'rspec',         '~> 2.7.0'
  s.add_development_dependency 'simplecov',     '~> 0.5.4'
  s.add_development_dependency 'mocha',         '~> 0.10.0'
  s.add_development_dependency 'guard-rspec',   '~> 0.5.10'
  s.add_development_dependency 'libnotify',     '~> 0.6.0'
end
