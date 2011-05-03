module ConfigureMe
  class Base
    class << self
      def persist_me(persistence_key = nil)
        if ConfigureMe.persistence_klass.nil?
          raise ::RuntimeError, "ConfigureMe: persistence_klass is not set.  Make sure you have an initializer to assign it."
        end
        @persisting = true
      end

      def persisting?
        @persisting ||= false
      end

      def persistence_key
        self.config_name
      end
    end
  end

  module Persisting
    def persistence_key(name)
      key = "#{self.class.persistence_key}_#{name.to_s}"
      key = @parent.persistence_key(key) unless @parent.nil?
      key
    end
  end
end
