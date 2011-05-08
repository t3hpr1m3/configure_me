require 'active_model'
require 'singleton'
require 'configure_me/attribute_methods'
require 'configure_me/caching'
require 'configure_me/loading'
require 'configure_me/naming'
require 'configure_me/nesting'
require 'configure_me/persisting'
require 'configure_me/setting'

module ConfigureMe
  class << self
    def persist_with(klass)
      @persistence_klass = klass
    end

    def persistence_klass
      @persistence_klass ||= ::Setting
    end
  end

  class Base
    include AttributeMethods
    include Nesting
    include Naming
    include Persisting
    include Caching
    include Singleton
    extend Loading
    include ActiveModel::Validations
    include ActiveModel::Conversion

    def persisted?
      true
    end

    def to_key
      if persisted?
        key = parent_config.nil? ? [] : parent_config.to_key
        key << self.class.config_name
        key
      else
        nil
      end
    end

    def to_param
      if persisted?
        to_key.join('-')
      else
        nil
      end
    end

    class << self
      def inherited(subclass)
        super
        configs << subclass
      end

      def config_name
        self.name.split('::').last.gsub(/^(.*)Config$/, '\1').underscore
      end

      def method_missing(method_sym, *args)
        if instance.respond_to?(method_sym)
          instance.send(method_sym, *args)
        else
          super
        end
      end

      def respond_to?(method_sym, include_private = false)
        instance.children.each_pair do |name, instance|
          if name.to_s.eql?(method_sym.to_s)
            return true
          end
        end
        if class_settings.key?(method_sym)
          return true
        end
        super
      end

      def find_by_id(id)
        configs.each do |config|
          if config.nested_name.eql?(id)
            return config.instance
          end
        end
        nil
      end

      private

      def configs
        @configs ||= []
      end
    end
  end
end
