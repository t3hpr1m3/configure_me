module ConfigureMe
  class Base
    class << self
      def cache_me(caching_key = nil)
        @caching = true
      end

      def caching?
        @caching ||= false
      end
    end
  end

  module Caching
    def write_cache(name, value)
      if defined?(Rails) && self.class.caching?
        Rails.cache.write(cache_key(name), value)
      end
    end

    def read_cache(name)
      if defined?(Rails) && self.class.caching?
        Rails.cache.read(cache_key(name))
      else
        nil
      end
    end

    def cache_key(name)
      persistence_key(name)
    end
  end
end
