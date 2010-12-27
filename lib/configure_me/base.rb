require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'

module ConfigureMe
  class Base
    include ActiveModel::AttributeMethods

    attribute_method_suffix('', '=')

    class << self
      @persisting = false
      @persistence_klass = nil

      def setting(name, type, options = {})
        new_setting = Setting.new(self, name, type, options)
        class_settings[name] = new_setting
        new_setting.define_methods!
      end

      def class_settings
        @class_settings ||= {}.with_indifferent_access
      end

      def define_attribute_methods(force = false)
        return unless class_settings
        undefine_attribute_methods if force
        super(class_settings.keys)
      end

      def persist_me(persistence_key = nil, klass = nil)
        raise ::RuntimeError, "configure_me - Unable to persist without ActiveRecord" unless defined?(ActiveRecord)
        require 'configure_me/persisted_setting'
        @persisting = true
        @persistence_klass = klass || PersistedSetting
      end

      def persisting?
        @persisting
      end

      def persistence_klass
        @persistence_klass
      end

      def persistence_key
        self.name.underscore.gsub(/^(.*)_config$/, '\1')
      end
    end

    def initialize(parent = nil, settings = {})
      @parent = parent
      @settings = settings_from_class_settings
    end

    def settings_from_class_settings
      self.class.class_settings.inject({}.with_indifferent_access) do |settings, (name, setting)|
        settings[name] = setting.default
        settings
      end
    end

    def read_setting(name)
      if self.class.persisting?
        setting = self.class.persistence_klass.find_by_key(persistence_key(name))
        if setting.nil?
          @settings[name.to_sym]
        else
          YAML::load(setting.value)
        end
      else
        @settings[name.to_sym]
      end
    end

    def write_setting(name, value)
      if self.class.persisting?
        setting = self.class.persistence_klass.find_or_create_by_key(persistence_key(name))
        setting.value = value.to_yaml
        setting.save!
      else
        if self.class.class_settings[name]
          @settings[name.to_sym]  = value
        else
          raise NoMethodError, "Unknown setting: #{name.inspect}"
        end
      end
    end

    protected

    def attribute_method?(name)
      self.class.class_settings.key?(name)
    end

    private

    def settings=(new_settings)
      return unless new_settings.is_a?(Hash)
      settings = new_settings.stringify_keys

      settings.each do |k, v|
        respond_to?("#{k}=".to_sym) ? send("#{k}=".to_sym, v) : raise(UnknownMethodError, "Unknown setting: #{k}")
      end
    end

    def attribute(name)
      read_setting(name.to_sym)
    end

    def attribute=(name, value)
      write_setting(name.to_sym, value)
    end

    def persistence_key(name)
      key = "#{self.class.persistence_key}_#{name.to_s}"
      key = @parent.persistence_key(key) unless @parent.nil?
      key
    end

  end
end
