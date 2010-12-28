require 'active_support/concern'

module ConfigureMe
  module Persistence
    extend ActiveSupport::Concern

    included do
      @persisting = false
    end

    module ClassMethods
      def persist_me(persistence_key = nil)
        if ConfigureMe.persistence_klass.nil?
          raise ::RuntimeError, "configure_me - persistence_klass is not set.  Make sure you have an initializer to assign it."
        end
        @persisting = true
      end

      def persisting?
        @persisting
      end

      def persistence_key
        self.config_name
      end
    end

    def persistence_key(name)
      key = "#{self.class.persistence_key}_#{name.to_s}"
      key = @parent.persistence_key(key) unless @parent.nil?
      key
    end
  end
end
