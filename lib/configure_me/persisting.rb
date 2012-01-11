module ConfigureMe
  module Persisting
    extend ActiveSupport::Concern

    module ClassMethods
      def persist_me
        @persisting = true
      end

      def persisting?
        @persisting ||= false
        @persisting && !ConfigureMe.persistence_klass.nil?
      end
    end

    def read_persist(name)
      if self.class.persisting?
        setting = ConfigureMe.persistence_klass.find_by_key(self.storage_key(name))

        unless setting.nil?
          YAML.load(setting.value)
        end
      else
        nil
      end
    end

    def write_persist(name, value)
      if self.class.persisting?
        setting = ConfigureMe.persistence_klass.find_or_create_by_key(self.storage_key(name))
        setting.value = value.to_yaml
        setting.save!
      else
        true
      end
    end

    def persist_guard(&block)
      if ConfigureMe.persistence_klass.respond_to?(:transaction)
        ConfigureMe.persistence_klass.transaction({}, &block)
      else
        block.call
      end
    end
  end
end
