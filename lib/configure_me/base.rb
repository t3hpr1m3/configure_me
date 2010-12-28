require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'
require 'singleton'
require 'configure_me/persistence'
require 'configure_me/caching'
require 'configure_me/settings'
require 'configure_me/nesting'

module ConfigureMe
  class Base
    include ActiveModel::AttributeMethods
    include Settings
    include Persistence
    include Caching
    include Nesting
    include Singleton
    extend ActiveModel::Naming

    class << self
      def config_name
        self.name.split('::').last.gsub(/^(.*)Config$/, '\1').downcase
      end
    end

    def parent
      @parent || nil
    end

    def parent=(parent)
      @parent = parent
    end

    def initialize
      @children = {}
      @settings = settings_from_class_settings
      self.class.nested.each do |klass|
        nest(klass)
      end
    end
  end
end
