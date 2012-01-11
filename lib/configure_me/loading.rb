require 'yaml'

module ConfigureMe
  module Loading
    def from_hash(root, config)

      # Determine how many root keys there are.
      #
      # If more than one, create a new nested ConfigureMe::Base
      # subclass for each key.
      #
      # If only one, just assign the values to the root config
      if config.keys.length > 1
        if root.nil?
          root = define_custom_class('RootConfig')
        end
        config.each_pair do |key, value|
          if value.is_a?(Hash)
            klass_name = "#{key}_config".camelize
            c = define_custom_class("#{key}_config".camelize)
            from_hash(c, value)
            c.send :nest_me, root
          else
            root.send :setting, key, :default => value
          end
        end
        root
      else
        root = define_custom_class(config.keys.first.to_s.camelize)
        from_hash(root, config.values.first)
      end
    end

    def load(*args)
      case args.first
      when Hash
        from_hash(nil, args.first)
      when String
        if File.exists?(args.first)
          yml = YAML::load(File.open(args.first))
          from_hash(nil, yml)
        else
          raise ::ArgumentError, "ConfigureMe: Invalid file: #{args.first}"
        end
      else
        raise ::ArgumentError, "ConfigureMe: Not sure how to load type [#{args.class}]"
      end
    end

    private

    def define_custom_class(name)
      Object.send(:remove_const, name) if Object.const_defined?(name)
      Object.const_set(name, Class.new(ConfigureMe::Base))
    end
  end
end
