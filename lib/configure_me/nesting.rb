module ConfigureMe
  class Base
    class << self
      def nest_me(klass, name = nil)
        klass.instance.nest(self)
      end
    end
  end

  module Nesting

    def nest(klass)
      children[klass.instance.config_name.to_sym] = klass.instance
      klass.instance.parent_config = self
      self.class_eval <<-EOF, __FILE__, __LINE__
        def #{klass.instance.config_name}
          children[:#{klass.instance.config_name.to_s}]
        end
      EOF
    end

    def parent_config
      @parent_config ||= nil
    end

    def parent_config=(parent_config)
      @parent_config = parent_config
    end

    def children
      @children ||= {}
    end

    def all_configs
      res = [self]
      children.values.each do |child|
        res.concat(child.all_configs)
      end
      res
    end
  end
end
