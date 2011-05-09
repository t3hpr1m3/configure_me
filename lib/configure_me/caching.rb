module ConfigureMe
  class Base
    class << self
      def cache_me
        @caching = true
      end

      def caching?
        @caching ||= false
        @caching && !ConfigureMe.cache_object.nil?
      end
    end
  end

  module Caching
    def read_cache(name)
      if self.class.caching?
        ConfigureMe.cache_object.read(self.storage_key(name))
      else
        nil
      end
    end

    def write_cache(name, value)
      if self.class.caching?
        ConfigureMe.cache_object.write(self.storage_key(name), value)
      end
    end
  end
end
