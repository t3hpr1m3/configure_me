require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'rspec/core'
require 'support/active_model_lint'

require 'configure_me'

RSpec.configure do |config|
  config.mock_with :mocha
end

class Setting; end
class BaseTestConfig
  include ConfigureMe::Naming
end
