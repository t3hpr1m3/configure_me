require 'active_support/concern'

module ConfigureMe
  module Caching
    extend ActiveSupport::Concern

    included do
      @caching = false
    end

    module ClassMethods
      def cache_me(caching_key = nil)
        @caching = true
      end

      def caching?
        @caching
      end
    end

    def cache_key(name)
      persistence_key(name)
    end
  end
end
