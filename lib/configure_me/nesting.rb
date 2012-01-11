module ConfigureMe
  module Nesting
    extend ActiveSupport::Concern

    module ClassMethods
      def nest_me(klass, name = nil)
        klass.nested_classes[self.config_name.to_sym] = self
        klass.class_eval <<-EOF, __FILE__, __LINE__
          def #{self.config_name}
            @#{self.config_name} ||= begin
              config = self.class.nested_classes["#{self.config_name}".to_sym].new
              config.parent_config = self
              self.children["#{self.config_name}".to_sym] = config
              config
            end
          end
        EOF
      end

      def nested_classes
        @nested_classes ||= {}
      end
    end

    module InstanceMethods

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
end
