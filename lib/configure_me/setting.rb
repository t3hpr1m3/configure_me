module ConfigureMe
  class Setting
    attr_reader :name, :type, :default

    def initialize(owner, name, type, *args)
      options = args.extract_options!

      @owner, @name, @type = owner, name.to_s
      @default = options.key?(:default) ? options[:default] : nil
    end

    def define_methods!
      @owner.define_attribute_methods(true)
    end

    def convert(value)
      case type
      when :string    then value
      when :text      then value
      when :integer   then value.to_i rescue value ? 1 : 0
      when :float     then value.to_f
      when :date      then ActiveRecord::ConnectionAdapters::Column.string_to_date(value)
      else value
      end
    end
  end
end
