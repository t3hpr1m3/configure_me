module ConfigureMe
  class << self
    def persist_with(klass)
      @persistence_klass = klass
    end

    def persistence_klass
      @persistence_klass ||= nil
    end
  end
end
require 'configure_me/setting'
require 'configure_me/base'
