module ConfigureMe
  class Base
    class << self
      def cache_me
        @caching = true
      end

      def caching?
        @caching ||= false
      end

      def cache_key(name)
        persistence_key(name)
      end
    end
  end

  module Caching
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
