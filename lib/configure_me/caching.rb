module ConfigureMe
  module Caching
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def cache_me
        @caching = true
      end

      def caching?
        @caching ||= false
      end

      def cache_key(name)
        key = "#{self.config_name}_#{name.to_s}"
        key = parent_config.class.cache_key(key) unless parent_config.nil?
        key
      end
    end
    def write_cache(name, value)
      if defined?(Rails) && self.class.caching?
        Rails.cache.write(self.class.cache_key(name), value)
      end
    end

    def read_cache(name)
      if defined?(Rails) && self.class.caching?
        Rails.cache.read(self.class.cache_key(name))
      else
        nil
      end
    end
  end
end
