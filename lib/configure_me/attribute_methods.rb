require 'active_record'

module ConfigureMe
  module AttributeMethods

    def self.included(base)
      base.send(:include, ActiveModel::AttributeMethods)
      base.send(:include, ActiveModel::Dirty)
      base.send(:attribute_method_suffix, '', '=')
      base.extend(ActiveModel::Callbacks)
      base.send(:define_model_callbacks, :save)
      base.extend(ClassMethods)
    end

    module ClassMethods
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

    def save
      run_callbacks :save do
        ActiveRecord::Base.transaction do
          temp_attributes.each_pair do |k,v|
            write_persist(k, v)
          end
        end
        temp_attributes.each_pair do |k,v|
          write_cache(k, v)
        end
        temp_attributes.clear
        @changed_attributes.clear
      end
      true
    end

    def update_attributes(new_attrs)
      new_attrs.each_pair do |k,v|
        send :attribute=, k, v
      end
      save
    end

    private

    def temp_attributes
      @temp_attributes ||= {}
    end

    def attributes
      attrs = {}
      self.class.class_settings.keys.each do |key|
        attrs[key.to_s] = attribute(key)
      end
      attrs
    end

    def attribute(name)
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

      self.class.class_settings[name_sym].convert(value)
    end

    def attribute=(name, value)
      name_sym = name.to_sym
      self.send("#{name.to_s}_will_change!")
      temp_attributes[name_sym] = value
    end
  end
end
