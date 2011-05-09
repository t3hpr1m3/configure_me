module ConfigureMe
  class Base
    extend ActiveModel::Naming

    class << self
      def model_name
        if persisting?
          ConfigureMe.persistence_klass.model_name
        else
          super
        end
      end
    end
  end

  module Naming
  end
end
