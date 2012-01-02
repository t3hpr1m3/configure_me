require 'rubygems'
require 'simplecov'
SimpleCov.start
require 'bundler/setup'
Bundler.require(:default)
require 'rspec/core'
require 'support/active_model_lint'

require 'configure_me'

RSpec.configure do |config|
  config.mock_with :mocha
end

def define_test_class(name, base)
  Object.send(:remove_const, name.to_sym) if Object.const_defined?(name)
  Object.const_set(name, Class.new(base))
end
