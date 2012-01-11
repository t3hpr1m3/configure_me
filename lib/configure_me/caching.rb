module ConfigureMe
  module Caching
    extend ActiveSupport::Concern

    module ClassMethods
      def cache_me
        @caching = true
      end

      def caching?
        @caching ||= false
        @caching && !ConfigureMe.cache_object.nil?
      end
    end

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
