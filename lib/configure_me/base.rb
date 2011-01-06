require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'
require 'singleton'
require 'configure_me/settings'
require 'configure_me/nesting'
require 'configure_me/persisting'
require 'configure_me/caching'

module ConfigureMe
  class Base
    include ActiveModel::AttributeMethods
    include Settings
    include Nesting
    include Persisting
    include Caching
    include Singleton
    extend ActiveModel::Naming

    class << self
      def config_name
        self.name.split('::').last.gsub(/^(.*)Config$/, '\1').downcase
      end

      def from_hash(root, config)
        if root.nil?
          root = const_set("RootConfig", Class.new(ConfigureMe::Base))
        end

        # Determine how many root keys there are.
        #
        # If more than one, create a new nested ConfigureMe::Base
        # subclass for each key.
        #
        # If only one, just assign the values to the root config
        if config.keys.length > 1
          config.each_pair do |key, value|
            if value.is_a?(Hash)
              klass_name = "#{key}_config".camelize
              c = root.const_set(klass_name, Class.new(ConfigureMe::Base))
              from_hash(c, value)
              c.send :nest_me, root
            else
              root.send :setting, key, :string, :default => value
            end
          end
          root
        else
          from_hash(root, config.values.first)
        end
      end

      def load(config)
        case config
        when Hash
          from_hash(nil, config)
        else
          raise ::ArgumentError, "ConfigureMe: Not sure how to load type [#{config.class}]"
        end
      end

      def method_missing(method, *args)
        if instance.respond_to?(method)
          instance.send(method, *args)
        else
          super
        end
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
