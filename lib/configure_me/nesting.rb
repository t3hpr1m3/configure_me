module ConfigureMe
  class Base
    class << self
      @@nested = []
      def nest_me(klass, name = nil)
        klass.nest(self)
        @nested_name = name || klass.config_name
      end

      def nested
        @nested ||= []
      end

      def nest(klass)
        nested << klass
      end
    end
  end

  module Nesting
    def nest(klass)
      @children[klass.config_name] = klass.instance
      klass.instance.parent = self
      self.class_eval <<-EOF, __FILE__, __LINE__
        def #{klass.config_name}
          @children['#{klass.config_name}']
        end
      EOF
    end
  end
end
