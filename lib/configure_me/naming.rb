require 'active_model/naming'

module ConfigureMe
  module Naming
    def self.included(base)
      base.extend(ActiveModel::Naming)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def config_name
        self.name.split('::').last.gsub(/^(.*)Config$/, '\1').underscore
      end
    end

    def to_param
    end
  end
end
