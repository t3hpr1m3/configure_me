module ConfigureMe
  module Persistence
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :save
    end

    def save(*)
      run_callbacks :save do
        persist_guard do
          temp_attributes.each_pair do |k,v|
            write_persist(k, v)
          end
        end
        temp_attributes.each_pair do |k,v|
          write_cache(k, v)
        end
        make_clean
      end
    end

    def update_attributes(new_attrs)
      new_attrs.each_pair do |k,v|
        write_attribute(k, v)
      end
      save
    end
  end
end
