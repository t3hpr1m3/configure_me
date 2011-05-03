require 'active_record/connection_adapters/abstract/schema_definitions'

module ConfigureMe
  class InvalidDefault < StandardError; end
  class UnsupportedType < StandardError; end
  class InvalidConversion < StandardError; end
  # == Setting
  #
  # There are two methods used to create a setting:
  # 1. calling the class method <tt>setting</tt> from within an instance of ConfigureMe::Base
  # 2. implicitly when a hash is fed to ConfigureMe::Base.load
  class Setting
    attr_reader :name, :type, :default

    VALID_TYPES = [:string, :integer, :float, :boolean, :unknown]
    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']

    def initialize(owner, name, *args)
      options = args.extract_options!

      @owner, @name = owner, name.to_s
      @default = options.key?(:default) ? options[:default] : nil
      @type = options.key?(:type) ? options[:type] : infer_type(@default)
      raise UnsupportedType.new("Invalid type: #{@type}") unless VALID_TYPES.include?(@type)
    end

    def convert(value)
      case type
      when :string    then convert_to_string(value)
      when :integer   then value.to_i rescue value ? 1 : 0
      when :float     then value.to_f rescue value ? 1.0 : 0.0
      when :boolean   then convert_to_boolean(value)
      when :unknown
        @type = infer_type(value)
        convert(value)
      end
    end

    private

    def infer_type(value)
      case value
      when String
        :string
      when Fixnum
        :integer
      when Float
        :float
      when TrueClass, FalseClass
        :boolean
      when NilClass
        :unknown
      else
        raise InvalidDefault.new("Unable to infer type from #{value.inspect}")
      end
    end

    def convert_to_string(value)
      case value
      when String
        value
      when Fixnum, Float, TrueClass, FalseClass, NilClass
        value.to_s
      else
        raise InvalidConversion.new("Unable to convert #{value.inspect} to string")
      end
    end

    def convert_to_boolean(value)
      if value.is_a?(String) && value.blank?
        nil
      else
        TRUE_VALUES.include?(value)
      end
    end
  end
end
