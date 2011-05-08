module ConfigureMe
  module Nesting
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def nest_me(klass, name = nil)
        klass.instance.nest(self)
      end
    end

    def nest(klass)
      children[klass.config_name] = klass.instance
      klass.instance.parent_config = self
      self.instance_eval <<-EOF, __FILE__, __LINE__
        def #{klass.config_name}
          children['#{klass.config_name}']
        end
      EOF
    end

    def nested_name
      if parent_config.nil?
        self.class.config_name
      else
        "#{parent_config.nested_name}-#{self.class.config_name}"
      end
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
