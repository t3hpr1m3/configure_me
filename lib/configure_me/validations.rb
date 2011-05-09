require 'active_model'

module ConfigureMe
  class Base
    include ActiveModel::Validations
    define_model_callbacks :validation

    def save(options={})
      run_callbacks :validation do
        perform_validations(options) ? super : false
      end
    end

    def valid?(context = nil)
      context ||= (persisted? ? :update : :create)
      output = super(context)
      errors.empty? && output
    end

    protected

    def perform_validations(options={})
      if options[:validate] != false
        valid?(options[:context])
      else
        true
      end
    end
  end

  module Validations
  end
end
