require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'rspec/core'

require 'configure_me'

RSpec.configure do |config|
  config.mock_with :mocha
end
