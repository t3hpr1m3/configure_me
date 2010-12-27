module ConfigureMe
  class Setting
    attr_reader :name, :type, :default

    def initialize(owner, name, type, *args)
      options = args.extract_options!

      @owner, @name, @type = owner, name.to_s, type
      @default = options.key?(:default) ? options[:default] : nil
    end

    def define_methods!
      @owner.define_attribute_methods(true)
    end
  end
end
