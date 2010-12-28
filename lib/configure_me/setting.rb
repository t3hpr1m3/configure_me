module ConfigureMe
  class Setting
    attr_reader :name, :default

    def initialize(owner, name, *args)
      options = args.extract_options!

      @owner, @name = owner, name.to_s
      @default = options.key?(:default) ? options[:default] : nil
    end

    def define_methods!
      @owner.define_attribute_methods(true)
    end
  end
end
