module ConfigureMe
  module Nesting
    extend ActiveSupport::Concern

    module ClassMethods
      def nest_me(klass, name = nil)
        klass.nested_classes[self.config_name.to_sym] = self
        self.parent_config_klass = klass
        klass.class_eval <<-EOF, __FILE__, __LINE__
          def #{self.config_name}
            @#{self.config_name} ||= begin
              config = self.class.nested_classes["#{self.config_name}".to_sym].new
              self.children["#{self.config_name}".to_sym] = config
              config
            end
          end
        EOF
      end

      def nested_classes
        @nested_classes ||= {}
      end

      def parent_config_klass
        @parent_config_klass ||= nil
      end

      def parent_config_klass=(parent_config_klass)
        @parent_config_klass = parent_config_klass
      end
    end

    module InstanceMethods

      def parent_config
        self.class.parent_config_klass ? self.class.parent_config_klass.new : nil
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
