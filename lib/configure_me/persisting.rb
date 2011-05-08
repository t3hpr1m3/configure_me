module ConfigureMe
  module Persisting
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def persist_me(persistence_key = nil)
        if ConfigureMe.persistence_klass.nil?
          raise ::RuntimeError, "ConfigureMe: persistence_klass is not set.  Make sure you have an initializer to assign it."
        end
        @persisting = true
      end

      def persisting?
        @persisting ||= false
      end

      def persistence_key(name)
        key = "#{self.config_name}_#{name.to_s}"
        key = parent_config.class.persistence_key(key) unless parent_config.nil?
        key
      end
    end
    def read_persist(name)
      if self.class.persisting?
        setting = ConfigureMe.persistence_klass.find_by_key(self.class.persistence_key(name))

        unless setting.nil?
          YAML.load(setting.value)
        end
      else
        nil
      end
    end

    def write_persist(name, value)
      if self.class.persisting?
        setting = ConfigureMe.persistence_klass.find_or_create_by_key(self.class.persistence_key(name))
        setting.value = value.to_yaml
        setting.save!
      else
        true
      end
    end
  end
end
