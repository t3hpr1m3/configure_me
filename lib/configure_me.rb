require 'active_model'
require 'active_support'

module ConfigureMe
  class << self
    def init(options = {})
      options = {:persist_with => nil, :cache_with => nil}.merge(options)
      @persistence_klass = options[:persist_with]
      @cache_object = options[:cache_with]
    end

    def persistence_klass
      @persistence_klass ||= nil
    end

    def cache_object
      @cache_object
    end
  end
end

require 'configure_me/attribute_methods'
require 'configure_me/caching'
require 'configure_me/loading'
require 'configure_me/naming'
require 'configure_me/nesting'
require 'configure_me/persistence'
require 'configure_me/persisting'
require 'configure_me/setting'
require 'configure_me/validations'
require 'configure_me/base'
