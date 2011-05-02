require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/kernel/singleton_class'
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
        self.name.split('::').last.gsub(/^(.*)Config$/, '\1').underscore
      end

      def from_hash(root, config)

        # Determine how many root keys there are.
        #
        # If more than one, create a new nested ConfigureMe::Base
        # subclass for each key.
        #
        # If only one, just assign the values to the root config
        if config.keys.length > 1
          if root.nil?
            root = define_custom_class('RootConfig')
          end
          config.each_pair do |key, value|
            if value.is_a?(Hash)
              klass_name = "#{key}_config".camelize
              c = define_custom_class("#{key}_config".camelize)
              from_hash(c, value)
              c.send :nest_me, root
            else
              root.send :setting, key, :string, :default => value
            end
          end
          root
        else
          if const_defined?(config.keys.first.to_s.camelize)
            remove_const(config.keys.first.to_s.camelize.to_sym)
          end
          root = const_set(config.keys.first.to_s.camelize, Class.new(ConfigureMe::Base))
          from_hash(root, config.values.first)
        end
      end

      def load(*args)
        case args.first
        when Hash
          from_hash(nil, args.first)
        else
          raise ::ArgumentError, "ConfigureMe: Not sure how to load type [#{args.class}]"
        end
      end

      def method_missing(method_sym, *args)
        if instance.respond_to?(method_sym)
          instance.send(method_sym, *args)
        else
          super
        end
      end

      def respond_to?(method_sym, include_private = false)
        nested.each do |klass|
          if klass.config_name.eql?(method_sym.to_s)
            return true
          end
        end
        if class_settings.key?(method_sym)
          return true
        end
        super
      end

      def define_custom_class(name)
        remove_const(name.to_sym) if const_defined?(name)
        const_set(name, Class.new(ConfigureMe::Base))
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
