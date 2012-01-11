module ConfigureMe
  module Naming
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Naming
      extend OverriddenClassMethods
    end

    module OverriddenClassMethods
      def model_name
        if persisting?
          ConfigureMe.persistence_klass.model_name
        else
          super
        end
      end
    end
  end
end
