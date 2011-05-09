module ConfigureMe
  class Base
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty
    attribute_method_suffix('', '=', '_before_type_cast')

    class << self
      def setting(name, *args)
        class_settings[name.to_sym] = Setting.new(name.to_sym, *args)
        define_attribute_methods(true)
      end

      def class_settings
        @class_settings ||= {}
      end

      def define_attribute_methods(force = false)
        return if class_settings.empty?
        undefine_attribute_methods if force
        super(class_settings.keys)
      end
    end
  end
  module AttributeMethods

    def read_attribute(name)
      name_sym = name.to_sym
      value = attribute_before_type_cast(name)
      self.class.class_settings[name_sym].convert(value)
    end

    def write_attribute(name, value)
      name_sym = name.to_sym
      make_dirty(name_sym)
      temp_attributes[name_sym] = value
    end

    private

    def temp_attributes
      @temp_attributes ||= {}
    end

    def make_dirty(name)
      self.send("#{name.to_s}_will_change!")
    end

    def make_clean
      temp_attributes.clear
      @changed_attributes.clear if defined?(@changed_attributes)
    end

    def attributes
      attrs = {}
      self.class.class_settings.keys.each do |key|
        attrs[key.to_s] = attribute(key)
      end
      attrs
    end

    def attribute_before_type_cast(name)
      name_sym = name.to_sym
      if self.send "#{name.to_s}_changed?".to_sym
        value = temp_attributes[name_sym]
      else
        value = read_cache(name_sym)
        if value.nil?
          value = read_persist(name_sym)
          unless value.nil?
            write_cache(name_sym, value)
          end
        end
        if value.nil?
          value = self.class.class_settings[name_sym].default
        end
      end
      value
    end

    def attribute(name)
      read_attribute(name)
    end

    def attribute=(name, value)
      write_attribute(name, value)
    end
  end
end
