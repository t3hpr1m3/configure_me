module ConfigureMe
  module Identity
    def config_key
      to_param
    end

    def config_name
      self.class.name.split('::').last.gsub(/^(.*)Config$/, '\1').underscore
    end

    def storage_key(name)
      "#{config_key}-#{name.to_s}"
    end
  end
end
