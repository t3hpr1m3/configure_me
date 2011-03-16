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
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_dependency 'activemodel',   '~> 3.0.1'
  s.add_dependency 'activesupport', '~> 3.0.1'

  s.add_development_dependency 'rspec',     '~> 2.0.1'
  s.add_development_dependency 'rcov',      '~> 0.9.9'
  s.add_development_dependency 'mocha',     '~> 0.9.8'
  s.add_development_dependency 'activerecord',  '~> 3.0.1'
end
