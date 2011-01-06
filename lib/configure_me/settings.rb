require 'active_support/concern'

module ConfigureMe
  module Settings
    extend ActiveSupport::Concern

    included do
      attribute_method_suffix('', '=')
    end

    module ClassMethods
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
    end

    def settings_from_class_settings
      self.class.class_settings.inject({}.with_indifferent_access) do |settings, (name, setting)|
        settings[name] = setting.default
        settings
      end
    end

    def read_setting(name)
      value = nil
      if self.class.caching?
        value = Rails.cache.read(cache_key(name))
      end

      if self.class.persisting? && value.nil?
        setting = ConfigureMe.persistence_klass.find_by_key(persistence_key(name))
        unless setting.nil?
          value = YAML::load(setting.value)
          if self.class.caching?
            Rails.cache.write(cache_key(name), value)
          end
          @settings[name.to_sym] = value
        end
      end

      value = @settings[name.to_sym] if value.nil?
      self.class.class_settings[name.to_sym].convert(value)
    end

    def write_setting(name, value)
      if self.class.class_settings[name]
        @settings[name.to_sym]  = value
      else
        raise NoMethodError, "ConfigureMe: Unknown setting: #{name.inspect}"
      end

      if self.class.caching?
        Rails.cache.write(cache_key(name), value)
      end

      if self.class.persisting?
        setting = ConfigureMe.persistence_klass.find_or_create_by_key(persistence_key(name))
        setting.value = value.to_yaml
        setting.save!
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
  end
end
