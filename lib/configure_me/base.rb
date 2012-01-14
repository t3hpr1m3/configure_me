

module ConfigureMe

  class Base
    extend ActiveModel::Callbacks
    include AttributeMethods
    include Caching
    include Naming
    include Nesting
    include Persistence
    include Persisting
    include Validations
    extend Loading
    include ActiveModel::Conversion

    def persisted?
      true
    end

    def to_key
      if persisted?
        key = parent_config.nil? ? [] : parent_config.to_key
        key << self.class.config_name
      else
        nil
      end
    end

    def to_param
      if persisted?
        to_key.join('-')
      else
        nil
      end
    end

    def storage_key(name)
      "#{to_param}-#{name.to_s}"
    end

    class << self
      def inherited(subclass)
        super
        configs << subclass
      end

      def config_key
        key = parent_config_klass.nil? ? [] : parent_config_klass.config_key
        key << self.config_name
        key
      end

      def config_name
        self.name.demodulize.gsub(/^(.*)Config$/, '\1').underscore
      end

      #def method_missing(method_sym, *args)
      #  if instance.respond_to?(method_sym)
      #    instance.send(method_sym, *args)
      #  else
      #    super
      #  end
      #end

      #def respond_to?(method_sym, include_private = false)
      #  instance.children.each_pair do |name, instance|
      #    if name.to_s.eql?(method_sym.to_s)
      #      return true
      #    end
      #  end
      #  if class_settings.key?(method_sym)
      #    return true
      #  end
      #  super
      #end

      def find_by_id(id)
        configs.each do |config|
          if config.config_name.eql?(id)
            return config.new
          end
        end
        nil
      end

      private

      def configs
        @configs ||= []
      end
    end
  end
end
